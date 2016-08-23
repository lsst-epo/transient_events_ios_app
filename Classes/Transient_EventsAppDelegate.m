//
//  Transient_EventsAppDelegate.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright Diffraction Limited Design LLC 2009. All rights reserved.
//



#import "Transient_EventsAppDelegate.h"
#import "EventListController.h"
//#import "EventListBackgroundView.h"
#import "SettingsController.h"
#import "SettingsListController.h"
//#import "BookmarkController.h"
#import "BookmarkListController.h"
#import "Constants.h"
#import "Locations.h"
#import "SurveyQuestion1ViewController.h"
#import "GlossaryController.h"

// WiFi checking
#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK

#define kTabBarTag 4096

#define kLontitudeIndex 3
#define kLatitudeIndex	4
#define	kAltitudeIndex	5
#define kNameIndex		6


@implementation Transient_EventsAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize registered;
@synthesize devToken;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {      
//	NSLog(@"AppDelegate: Launch options at launch.  Contents:\n%@",[launchOptions description]);
//	NSLog(@"AppDelegate: Font Families = %@", [UIFont familyNames]);
//	NSLog(@"AppDelegate: Georgia Fonts = %@", [UIFont fontNamesForFamilyName:@"Georgia"]);
	self.registered = NO;
	self.devToken = nil;
	//Clear the application icon badge
	app.applicationIconBadgeNumber=0;
    //Instantiate the tab bar controller
	UITabBarController *aTabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
	
	//now instantiate each of the list controllers and give each one its own navigation controller.
//	EventListController *eventController = [[EventListController alloc] initWithStyle:UITableViewStyleGrouped];
	EventListController *eventController = [[EventListController alloc] init];
//	EventListBackgroundView *eventController = [[EventListBackgroundView alloc] initWithNibName:@"EventListBackgroundView" bundle:nil];
	UINavigationController *eventNavController = [[UINavigationController alloc] initWithRootViewController:eventController];
	eventController.navController = eventNavController;
//	SettingsListController *settingsController = [[SettingsListController alloc] initWithStyle:UITableViewStyleGrouped];
	SettingsListController *settingsController = [[SettingsListController alloc] init];
	UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsController];
	settingsController.navController = settingsNavController;
	BookmarkListController *bookmarkController = [[BookmarkListController alloc] init];
	UINavigationController *bookmarkNavController = [[UINavigationController alloc] initWithRootViewController:bookmarkController];
	bookmarkController.navController = bookmarkNavController;
    
    GlossaryController *infoController = [[GlossaryController alloc] init];
    UINavigationController *infoNavController = [[UINavigationController alloc] initWithRootViewController:infoController];
    infoController.navController = infoNavController;
    
    
    
	NSArray *array;
	//Now add the controllers to the tab bar controller.
	NSString *testValue5 = [[NSUserDefaults standardUserDefaults] stringForKey:kTakeSurveyKey];
	if ((testValue5 == nil) || ([testValue5 intValue]!=kShowSurveyTab) ){
        NSString *device = @"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            device = @"SurveyQuestion1ViewController_iPad";
        }
        else
        {
            device = @"SurveyQuestion1ViewController";
        }
		SurveyQuestion1ViewController *surveyViewController = [[SurveyQuestion1ViewController alloc]initWithNibName:device bundle:nil];
		UINavigationController *surveyNavController = [[UINavigationController alloc] initWithRootViewController:surveyViewController];
		surveyViewController.navController = surveyNavController;
		array = [[NSArray alloc] initWithObjects:eventNavController,
                 bookmarkNavController,
                 settingsNavController,
                 surveyNavController,
                 infoNavController,
                 nil];
		
	}else{
		array = [[NSArray alloc] initWithObjects:eventNavController,
                 bookmarkNavController,
                 settingsNavController,
                 infoNavController,
                 nil];
		
	}
	aTabBarController.viewControllers = array;
	[array release];
	aTabBarController.view.tag = kTabBarTag;
	self.tabBarController = aTabBarController;
	//clean up memory
	[eventController release];
	[bookmarkController release];
	[settingsController release];
	[eventNavController release];
	[bookmarkNavController release];
	[settingsNavController release];
    [infoNavController release];
	[aTabBarController release];
	
	//Set the status bar style
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	
	//Call managedObjectContext to set the firstRun flag
	NSManagedObjectContext *context = self.managedObjectContext;
	//this next line gets rid of that annoying compile warning telling you that you have an unused variable.
	context = nil;
	//Do a little startup houskeeping
	[self setUserDefaults];
	[self handlePushPayload:launchOptions];
	[self deleteOldHistory];
	
	if (firstRun) {
		[self installDefaultStore];
	}
	//The following sleep command allows the initial LSST splash screen to remain
	//visible for 
	sleep(kSplashScreenDisplayTime);
	//Register for push notifications
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	if (YES) {
//		NSLog(@"AppDelegate: Registering for Push Notifications");
		[[UIApplication sharedApplication]
		 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
	}else{
		[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	}

	[window addSubview:self.tabBarController.view];

	[window makeKeyAndVisible];
	[self handlePushPayload:launchOptions];
    
    
    if (![self localWifiAvailable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kWifiNotificationTitle message:@"This application can use large amounts of data. If you have a limit on your data plan, you may want to wait until you are connected to WiFi before selecting 'Continue'." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Quit",nil];
        [alert show];
        [alert release];
    }
    
	//NOTE:  return value is ignored if this is the result of a remote notification
	//return value is used when app is launched in response to a registered URL
	//the app should return YES if it handles the URL schema, no if it does not.
	return YES;
}

/*
 * Method for testing if WiFi is connected
 */
- (BOOL)localWifiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
        if (cursor -> ifa_addr -> sa_family == AF_INET
            && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}




/**
 sets all default values for user defaults on first run.  Also checks the launchOptions dictionary for 
 information to see if there are any notifications so we can highlight any notifications.
*/

- (void)setUserDefaults{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *testValue = [userDefaults stringForKey:kLocationLatitudeKey];
	if (testValue == nil){
		[userDefaults setFloat:kLocationLatitudeDefault	forKey:kLocationLatitudeKey];
		[userDefaults setFloat:kLocationLongitudeDefault forKey:kLocationLongitudeKey];
		[userDefaults setFloat:kLocationAltitudeDefault forKey:kLocationAltitudeKey];
		[userDefaults setInteger:kEventAgeDefault forKey:kEventAgeKey];
		[userDefaults setFloat:kLimitingMagnitudeDefault forKey:kLimitingMagnitudeKey];
		NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"EventTypeDictionary" ofType:@"plist"];
		NSDictionary *eventDictionary = [[NSDictionary alloc] initWithContentsOfFile:defaultPath];

		[userDefaults setObject:eventDictionary forKey:kEventTypesKey];
		[eventDictionary release];
		[userDefaults setInteger:kRAFormatDefault forKey:kRAFormatKey];
		[userDefaults setBool:kVisibleObjectsOnlyDefault forKey:kVisibleObjectsOnlyKey];
		[userDefaults setBool:kAlertsOnDefault forKey:kAlertsOnKey];
		//Set the primary server

	}
//	NSString *testValue0 = [userDefaults stringForKey:kPrimaryEventServerKey];
//	if (testValue0 == nil){
		[userDefaults setObject:kPrimaryServerURL forKey:kPrimaryEventServerKey];
//	}
		
	[userDefaults setFloat:kLimitingMagnitudeLowerLimitDefault forKey:kLimitingMagnitudeLowerLimitKey];
	[userDefaults setFloat:kLimitingMagnitudeUpperLimitDefault forKey:kLimitingMagnitudeUpperLimitKey];
	[userDefaults setFloat:kMinimumAltitudeLowerLimit forKey:kMinimumAltitudeLowerLimitKey];
	[userDefaults setFloat:kMinimumAltitudeUpperLimit forKey:kMinimumAltitudeUpperLimitKey];
	[userDefaults setInteger:kEventAgeMaxiumumAgeDefault forKey:kEventAgeMaxiumumAgeKey];

	NSString *testValue1 = [userDefaults stringForKey:kMinAltitudeKey];
	if (testValue1 == nil){
		[userDefaults setInteger:kMinimumAltitudeDefault forKey:kMinAltitudeKey];
	}
	NSString *testValue2 = [userDefaults stringForKey:kLocationNameKey];
	if (testValue2 == nil){
		[userDefaults setObject:kLocationNameDefault forKey:kLocationNameKey];
	}
	NSString *testValue3 = [userDefaults stringForKey:kEventThumbnailsKey];
	if (testValue3 == nil) {
		[userDefaults setBool:kEventThumbnailsDefault forKey:kEventThumbnailsKey];
	}
	NSString *testValue4 = [userDefaults stringForKey:kFirstRunKey];
	if (testValue4 == nil) {
		[userDefaults setBool:YES forKey:kFirstRunKey];
		UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome to Transient Events", @"Welcome to Transient Events")
														message:NSLocalizedString(@"The Transient Events app displays results from active surveys.  The telescopes operate approximately 21 days every month and are closed during full moon when the skies are too bright.  The Arizona telescopes (CRTS and CRTS2) are also closed for most of July and August due to the local monsoons.  They may also be closed at other times due to weather or mechanical problems.\n Enjoy exploring!",
																				  @"Welcome Message")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Continue",@"Continue")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//Test to see if we want the user to take a survey.  Note that we returned if this was a first run.
	//That way they will not get two alerts the first time they run the program
	NSString *testValue5 = [userDefaults stringForKey:kTakeSurveyKey];
#ifdef LOGGING
	NSLog(@"AppDelegate: value of user defaults TakeSurveyKey = %@\n",testValue5);
#endif
	if ((testValue5 == nil) || ([testValue5 intValue]<=kNumberOfSurveyReminders) ) {
		if (testValue5 == nil) {
			[userDefaults setInteger:1  forKey:kTakeSurveyKey];
		}else {
			int nTries = [testValue5 intValue];
			nTries++;
			[userDefaults setInteger:nTries forKey:kTakeSurveyKey];
		}

		UIAlertView	*alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Help Us Improve Transient Events", @"Help Us Improve Transient Events")
														message:NSLocalizedString(@"Please take a short 2 question survey and give us your comments.\nNo personally identifying information will be transmitted.",
																				  @"Survey Message")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Not Now",@"Not Now")
											  otherButtonTitles:nil];
		[alert addButtonWithTitle:NSLocalizedString(@"Take Survey", @"Take Survey")];
		[alert show];
		[alert release];
	}
}
	
/**
 Handles the alert view responses.  This method gets called whenever the button in an alert view is pressed.
 Using the index of the button check the text and if it matches a condition which requires action then take the action
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView title] isEqualToString:kWifiNotificationTitle])
    {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Quit"])
        {
            // User wants to quit
            exit(EXIT_SUCCESS);
        }
    }
    else
    {
#ifdef LOGGING
        NSLog(@"AppDelegate: User pressed alertView Button %@\n",[alertView buttonTitleAtIndex:buttonIndex]);
#endif
        if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:NSLocalizedString(@"Take Survey", @"Take Survey")]) {
#ifdef LOGGING
            NSLog(@"AppDelegate: User selected to take survey now\n");
#endif
            self.tabBarController.selectedIndex = 3;
        }
    }
}

- (void)removeLastTab{
	if ([self.tabBarController.viewControllers count]>0) {
		NSMutableArray *controllers =[[NSMutableArray alloc] initWithArray:self.tabBarController.viewControllers];
		[[controllers lastObject] release];
		[controllers removeLastObject];
		self.tabBarController.viewControllers = controllers;
		[controllers release];
	}
}

		

/**
 Gets the push alert payload and checks to see if there are any event keys.  If so, it sets the eventID
 and stream source for each alert (we are assuming that we can only receive one event for now) in 
 user defaults.  EventListController will look for these keys and if they are found it will
 hightlight the data in that row.
 */

- (void)handlePushPayload:(NSDictionary *)launchOptions{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (launchOptions != nil) {
//		NSLog(@"AppDelegate: Launch options is not nil.  Contents:\n%@",[launchOptions description]);
		//set kAlertEventIDKey user defaults to eventID and kAlertStreamKey to alert event stream
		if ([launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] !=nil) {
			//This was passed in from applicaiton: didFinishLaunching, handle quietly
			NSDictionary *alertDict = [[NSDictionary alloc] initWithDictionary:[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
			if ([alertDict objectForKey:@"eventID"] !=nil ) {//test for alert events here
				[userDefaults setObject:[alertDict objectForKey:@"eventID"] forKey:kAlertEventIDKey];
				[userDefaults setObject:[alertDict objectForKey:@"eventStream"] forKey:kAlertStreamKey];
//				NSLog(@"AppDelegate: Alert at startup eventID = %@ ------- eventStream = %@",
//					  [userDefaults stringForKey:kAlertEventIDKey], [userDefaults stringForKey:kAlertStreamKey]);
				
			}else{
				if ([userDefaults objectForKey:kAlertEventIDKey] !=nil) {
					[userDefaults removeObjectForKey:kAlertEventIDKey];
				}
				if ([userDefaults objectForKey:kAlertStreamKey] !=nil) {
					[userDefaults removeObjectForKey:kAlertStreamKey];				
				}
			}
			[alertDict release];
			
		}else{
			//The alert was received while app was running - handle and put up an alert
			if ([launchOptions objectForKey:@"eventID"] !=nil ) {//test for alert events here
				[userDefaults setObject:[launchOptions objectForKey:@"eventID"] forKey:kAlertEventIDKey];
				[userDefaults setObject:[launchOptions objectForKey:@"eventStream"] forKey:kAlertStreamKey];
//				NSLog(@"AppDelegate: eventID = %@ ------- eventStream = %@",
//					  [userDefaults stringForKey:kAlertEventIDKey], [userDefaults stringForKey:kAlertStreamKey]);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Alert", @"New Alert") 
																message:[NSString stringWithFormat:@"%@ %@. %@", 
																		 NSLocalizedString(@"New Alert received from ",  @"New Alert Received Message"),
																		 [userDefaults stringForKey:kAlertStreamKey],
																		 NSLocalizedString(@"Reloading events", @"Reloading Events")]
															   delegate:nil 
													  cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") 
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			}else{
				if ([userDefaults objectForKey:kAlertEventIDKey] !=nil) {
					[userDefaults removeObjectForKey:kAlertEventIDKey];
				}
				if ([userDefaults objectForKey:kAlertStreamKey] !=nil) {
					[userDefaults removeObjectForKey:kAlertStreamKey];				
				}
			}
			
		}
		
		
		
	}else {
		//remove alert event items
		if ([userDefaults objectForKey:kAlertEventIDKey] !=nil) {
			[userDefaults removeObjectForKey:kAlertEventIDKey];
		}
		if ([userDefaults objectForKey:kAlertStreamKey] !=nil) {
			[userDefaults removeObjectForKey:kAlertStreamKey];
		}
	}

	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	//update the server with any changes to the types of alerts.
	if (self.devToken != nil) {
		[self sendProviderDeviceToken:self.devToken synchronously:YES];
	}


    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}
/**
 applicationWillResignActive:(UIApplication *)application saves changes the the managed object context
 and updates the server with the latest push options when the application goes into the background.
 This method was added for iOS4 since on iOS4 devices applications do not always quit when switching 
 to other tasks.  This results in the application living in the background for long periods.  Without
 this method a person may turn on/off alerts and the change would not be broadcast to the server
 for days if the app continued to live in the background. Now terminating or resiging active will both
 send any changes to the server.
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	//update the server with any changes to the types of alerts.
	if (self.devToken != nil) {
		[self sendProviderDeviceToken:self.devToken synchronously:YES];
	}
	
	//Save any database changes
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
	
}

#pragma mark -
#pragma mark Custom Methods

- (void)deleteOldHistory{
	//Get the history dictionary
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *history = [userDefaults objectForKey:kHistoryKey];
	//Define a place to put the obsolete keys
	NSMutableArray *obsoleteKeys = [[NSMutableArray alloc] init];
	NSString *key;
	//If there is a history dictionary we clean it up
	if (history) {
		//first we put the history in a mutable dictionary so we can modify it
		NSMutableDictionary *mutableHistory = [[NSMutableDictionary alloc] init];
		[mutableHistory addEntriesFromDictionary:history];
		//now scan all of the keys in the history
		for (key in history){
			//if the keys are older than kHistoryAge add them to the obsoleteKeys dictionary
			NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:[history objectForKey:key]];
			if (age > kHistoryAge) {
				[obsoleteKeys addObject:key];
			}
		}
		//Now we have all of the obsolete keys - remove them
		for (key in obsoleteKeys){
			[mutableHistory removeObjectForKey:key];
		}
		//Write the modified key dictionary back to userDefaults
		[userDefaults setObject:mutableHistory forKey:kHistoryKey];
		[mutableHistory release];
			
	}else{
		//There was no history dictionary so we will make an empty one and insert it in userDefaults
		NSDictionary *dict = [[NSDictionary alloc] init];
		[userDefaults setObject:dict forKey:kHistoryKey];
		[dict release];
	}
	//Clean up memory
	[obsoleteKeys release];

}
/**
 Initializes the default store.  
 
 Reads in the locations for the location list and puts the locations into the Core Data store
*/

- (void)installDefaultStore{
	Locations *location;
	//Get the path to the default list of locations
	NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Locations1000" ofType:@"txt"];
	//if we found the file then get the locations and add them to the data store
	if (defaultStorePath) {
		//Read the file
		NSString *locationsString = [[NSString alloc] initWithContentsOfFile:defaultStorePath];
		//Parse the file into lines
		NSArray *locationsArray = [[NSArray alloc] initWithArray:[locationsString componentsSeparatedByString:@"\n"]];
		[locationsString release];
		//Now iterate through the lines of data
		for (NSString *lineOfData in locationsArray){
			//Separate the elements in each line
			NSArray *locationArray = [[NSArray alloc] initWithArray:[lineOfData componentsSeparatedByString:@";"]];
			//Create a new object and insert it in the store
			location = (Locations *)[NSEntityDescription insertNewObjectForEntityForName:@"Locations"
																  inManagedObjectContext:managedObjectContext];
			//populate the new object
			location.Altitude = [NSNumber numberWithDouble:[[locationArray objectAtIndex:kAltitudeIndex] doubleValue]];
			location.Longitude = [NSNumber numberWithDouble:[[locationArray objectAtIndex:kLontitudeIndex] doubleValue]];
			location.Latitude = [NSNumber numberWithDouble:[[locationArray objectAtIndex:kLatitudeIndex] doubleValue]];
			location.Name = [locationArray objectAtIndex:kNameIndex];
			//Here is where we add the section name for each object, it is simply the first letter of the name
			location.SectionName = [location.Name substringToIndex:1];
			[locationArray release];
		}
		//We got everything, now save it
		NSError *error;
		if (![managedObjectContext save:&error]){
			NSLog(@"Unable to save default store:%@",[error localizedDescription]);
		}
	}
	
}



#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Transient_Events.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		firstRun = YES;
	}else {
		firstRun = NO;
	}

	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Transient_Events.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}



#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[devToken release];
	[tabBarController release];
    
	[window release];
	[super dealloc];
}

NSString *pushStatus ()
{
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
	@"Notifications were active for this application" :
	@"Remote notifications were not active for this application";
}


#pragma mark -
#pragma mark "Push Notification Delegate"
- (void)application:(UIApplication *)app 
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)theDevToken{
//	const void *devTokenBytes = [devToken bytes];
	self.devToken = theDevToken;
	self.registered = YES;
	[self sendProviderDeviceToken:self.devToken synchronously:NO];
//	NSLog(@"AppDelegate: Received Device Token %@",[self.devToken description]);
//	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//	NSString *results = [NSString stringWithFormat:@"Badge: %@, Alert:%@, Sound: %@",
//						 (rntypes & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No", 
//						 (rntypes & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No",
//						 (rntypes & UIRemoteNotificationTypeSound) ? @"Yes" : @"No"];
	
//	NSString *status = [NSString stringWithFormat:@"%@\nRegistration succeeded.\n\nDevice Token: %@\n%@", pushStatus(), self.devToken, results];
//	NSLog(@"Status = %@",status);
//	NSLog(@"deviceToken: %@", self.devToken); 
}

- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationWithError:(NSError *)err{
	NSLog(@"AppDelegate:Error in Push Notification Registration: %@",err);
}
/**
Called when a push notification is received while the app is running. Calls
 handlePushPayload: to put the event information into the user defaults database and 
 then post a notification that a reload is necessary
*/
- (void)application:(UIApplication *)app
didReceiveRemoteNotification:(NSDictionary *)userInfo{
	//userInfo should be the same as the launchOptions information so we need to
	//call handlePushPayloads and the tell the EventList controller to reload.
//	NSLog(@"AppDelegate: Received Remote Notification.  allKeys:\n%@",[userInfo allKeys]);
//	NSLog(@"AppDelegate: Received Remote Notification.  userInfo:\n%@",[userInfo description]);
//	NSLog(@"AppDelegate: Received Remote Notification.  subkeys:\n%@",[[userInfo valueForKey:@"aps"]allKeys]);
//	NSLog(@"AppDelegate: Received Remote Notification.  badge:\n%@",[[userInfo valueForKey:@"aps"]valueForKey:@"badge"]);	
	[self handlePushPayload:userInfo];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kAlertOccurredNotification object:self]];
}


#pragma mark -
#pragma mark Send device token to serer

/**
 Sends the device token to the LSST server.  The token is sent as 8 hex integers in big endien order.  It then appends POST
 query formatted information informing the server of they type of events for which the device is to receive alerts.
 sendProviderDeviceToken should be sent at startup and at shutdown (in the event options were changed during use).
*/

- (void)sendProviderDeviceToken:(NSData *)theDevToken synchronously:(BOOL)synchronous{
	unsigned int	devTokenInt[8];
	[theDevToken getBytes:&devTokenInt];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kPushServerURL]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest addValue:@"/jsonQuery/" forHTTPHeaderField:@"action"];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableString *formattedString = [NSMutableString stringWithFormat:@"deviceToken=%X,%X,%X,%X,%X,%X,%X,%X",
										CFSwapInt32(devTokenInt[0]),
										CFSwapInt32(devTokenInt[1]),
										CFSwapInt32(devTokenInt[2]),
										CFSwapInt32(devTokenInt[3]),
										CFSwapInt32(devTokenInt[4]),
										CFSwapInt32(devTokenInt[5]),
										CFSwapInt32(devTokenInt[6]),
										CFSwapInt32(devTokenInt[7])
										];
	
	//OK, now we need to append the desired event types
	//Lets get the event dictionary
	NSDictionary *eventDictionary = [[NSDictionary alloc] initWithDictionary:[userDefaults objectForKey:kEventTypesKey]];
	NSArray *keys = [eventDictionary allKeys];
	if ([userDefaults boolForKey:kAlertsOnKey]) {
		[formattedString appendFormat:@"&alertsOn=1"];
		[formattedString appendFormat:@"&notificationServer=%@",kNotificationServer];
		[formattedString appendFormat:@"&maxAge=%.2f",[userDefaults floatForKey:kEventAgeKey]];
		[formattedString appendFormat:@"&maxMagnitude=%f&streamNames=%@",
										[userDefaults floatForKey:kLimitingMagnitudeKey],kStreams
										];
		for (NSString *key in keys){
			if ([[eventDictionary objectForKey:key ] boolValue]){
				[formattedString appendFormat:@"&wantedClass=%@",key];
			}
		}
		
	}else {
		[formattedString appendFormat:@"&alertsOn=0"];
	}

//	NSLog(@"AppDelegate: Formatted Post String=\n%@",formattedString);
	[eventDictionary release];
	[formattedString replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [formattedString length])];
	//	NSLog(@"Formatted Post String=\n%@",formattedString);
	//Add the POST query to the message body
	NSString *bodyString = [[NSString alloc] initWithString:[formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	char buffer[[bodyString length]];
	NSUInteger usedLength;
	//put the bytes in a c-string buffer
	[bodyString getBytes:&buffer 
			   maxLength:[bodyString length] 
			  usedLength:&usedLength 
				encoding:NSUTF8StringEncoding 
				 options:NSStringEncodingConversionAllowLossy
				   range:NSMakeRange(0, [bodyString length])
		  remainingRange:NULL];
	//get the body text and make it data so we can add it to the URLRequest
	NSData *bodyData = [[NSData alloc] initWithBytes:buffer length:usedLength];
	[urlRequest setHTTPBody:bodyData];
	[bodyString release];
	[bodyData release];
	if (synchronous) {
		//Synchronous communications were requested.  This is typically done from applicationWillTerminate 
		NSURLResponse *urlResponse = nil;
		NSError *error = nil;
		NSData *returnData = nil;
//		NSLog(@"AppDelegate: Sending synchronous URL request to push server");
		returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
		NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
		if (error != nil) {
			NSLog(@"Unable to send synchronous registration request to LSST push server");
			NSLog(@"AppDelegate: urlRequest sent to push server\n returnData = %@\nurlResponse = %@\n,error = %@",
				  returnString, [urlResponse description], [error description]);
			
		}
		[returnString release];
	}else {
		//async connection requested
		NSURLConnection *urlConnection = nil;
//		NSLog(@"AppDelegate: Sending asynchronous URL request to push server");
		
		urlConnection = [NSURLConnection connectionWithRequest: urlRequest delegate: self];
		if (urlConnection == nil) {
				NSLog(@"AppDelegate:  Unable to connect to LSST push server with asynchronous request");
		}
		
	}

	[urlRequest release];
	
	
}


@end

