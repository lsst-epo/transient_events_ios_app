//
//  Transient_EventsAppDelegate.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright Diffraction Limited Design LLC 2009. All rights reserved.
//

/**
 @mainpage Transient Event iPhone App
 
 The Transient Event iPhone app allows the user to view transient events
 feeds on the iPhone.  The current release only displays events from the 
 Catalina real time transient survey.  Future releases will add additional 
 feeds.
 
 This work is sponsored by the LSST Corporation http://www.lsst.org
 
 App development by Bruce Truax of Diffraction Limited Design 
 http://www.dld-llc.com
 btruax@dld-llc.com
 
 \attention PROJECT NOTES: <br>All of the table view displays in this app originally inherited from UITableViewController.  This
 did not allow placing a non-scrolling background image in the table.  To allow a stationary background
 image all of the table views were changed to inherit from UIViewController.  These objects were then
 given a tableView property.  The view hierarchy is set up in the loadView method.  This method first 
 loads the background image into a UIImageView and then adds this as a subview of the main view.  Next 
 the tableView in instantiated using initWithFrame:style: and then teh table view is added to the
 view hierarchy.  Finally the tableView's datasource and delegate properties are set to self. <br><br>
 This method of setting the background image works well but there are some odd problems with the table
 views and getting them to look exactly right.  The most obvious way to setup the table view cells (the
 intent is to make them partially transparent) is to set their contentView.backgroundColor to the 
 desired color with an alpha of less than 1.  This works great until you add a disclosure indicator
 at which point the view behind the disclosure indicator becomes 100% transparent.  In order to get around
 this problem it is necessary to create a backgroundview and set it for each cell.  The background color
 of the background view can then be set to the desired color.  This works well except for one rather
 annoying side affect.  In grouped tables the top and bottom cells of the group no longer have rounded
 corners.  Numerous methods have been tried to get around this problem but no solution has been found.
 
 
 */
/**
 @brief The App Delegate for Transient Events
 
 As with all iPhone apps, the AppDelegate has delegate functions which, if implemented, are called
 by the main application once the program launch has completed.
 
 applicationDidFinishLaunching: method is called as soon as
 the application has launched by the main NSApplication object.  This method sets up the basic structure
 of the application and makes sure that all defaults are set properly.  The method sets up the Tab Bar 
 and the three primary controllers for events, bookmarks and settings.
 
 setUserDefaults:  called by application did finish launching. This method checks to see if 
 the user defaults have been set and if not, it sets the default values.  Each time new default(s)
 are added code is added to this method to try to read one of the defaults.  If the result comes back NIL then
 the values are set with defaults.  If the value is !NIL then the values have been set.  At this point
 there is no way to reset the defaults to their initial state except for deleting and reinstalling the app.
 Note that some defaults are set regardless of their previous state.  This allows the developer to set the
 defaults to new values with a new release. 
 
 applicationWillTerminate:  cleans up before the application quits.  The only function performed now is to
 save the manageObjectContext.  This saves the database which contains the bookmarks and the location list.
 
 deleteOldHistory - This method is called upon application launch.  It scans the history file and deletes items
 which are more than kHistoryAge old.  The history file is the file which allows links to appear greyed out 
 once they have been viewed.
 
 installDefaultStore - This method is called on the first run and only the first run.  This reads the list
 of locations from the Locations1000.plist file and inserts them into the CoreData store.  
 
 The remaining methods are all standard methods which are set up by the CoreData template.  The only 
 deviation is in persistantStoreCoordinator method where the firstRun flag is tested by determining if
 the .sqlite data store exists.

 
 */
@interface Transient_EventsAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {

    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	BOOL	registered;
	NSData	*devToken;
    UIWindow *window;
	
	UITabBarController	*tabBarController;
	
	BOOL firstRun;
}

- (IBAction)saveAction:sender;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSData* devToken;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (assign) BOOL registered;

- (void)setUserDefaults; //!<  used to initialize user defaults on first run or when new defaults are added 
- (void)deleteOldHistory; //!< deletes old event list browsing history
- (void)installDefaultStore; //!< if there is a default store to setup it is done in this method
- (void)sendProviderDeviceToken:(NSData *)devToken synchronously:(BOOL)synchronous; //!<Sends device token and desired event types to push server
- (void)handlePushPayload:(NSDictionary *)launchOptions; //!< decode and handle launch options
- (void)removeLastTab;
- (BOOL)localWifiAvailable; // Used to check if Wifi is connected at startup
@end

