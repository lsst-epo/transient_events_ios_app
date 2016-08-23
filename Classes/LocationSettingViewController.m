//
//  LocationSettingViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/2/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "LocationSettingViewController.h"
#import "Constants.h"
#import "PinAnnotation.h"
#import "Locations.h"
#import "LocationListController.h"
#import	"Constants.h"

#define kEarthCircumference	40074784

#define	kMap	0
#define	kSatellite 1
#define kHybrid	2

@implementation LocationSettingViewController


@synthesize mapView;
@synthesize longitude;
@synthesize latitude;
@synthesize textLocation;
@synthesize currentLocation;
@synthesize userDefaults;
@synthesize locationManager;
@synthesize	mapType;
@synthesize altitude;
@synthesize reverseGeocoder;
@synthesize	navController;
@synthesize	toolbar;
@synthesize	tintView;
@synthesize mapControl;


/**
 Default initializer call with nib named "LocationView.xib"
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Location", @"Location Page Title");
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/**
 @brief Fine tunes the look of the page and displays the current location from the userDefaults database.

 
 */
- (void)viewDidLoad {//! \private
	//start by setting the look of the text edit boxes
	self.longitude.borderStyle = UITextBorderStyleBezel;
	self.longitude.backgroundColor = [UIColor whiteColor];
	self.longitude.alpha = 0.75;
	self.latitude.borderStyle = UITextBorderStyleBezel;
	self.latitude.backgroundColor = [UIColor whiteColor];
	self.latitude.alpha = 0.75;
	self.altitude.borderStyle = UITextBorderStyleBezel;
	self.altitude.backgroundColor = [UIColor whiteColor];
	self.altitude.alpha = 0.75;
	self.textLocation.borderStyle = UITextBorderStyleBezel;
	self.textLocation.backgroundColor = [UIColor whiteColor];
	self.textLocation.alpha = 0.75;
	self.tintView.backgroundColor = kSettingsTableBackgroundColor;
	//When we enter this page we will always default to a hybrid map.
	self.mapType.selectedSegmentIndex = 2;
	self.userDefaults = [NSUserDefaults standardUserDefaults];
	//get the current location setting from the userDefaults database
	currentLocation.longitude = [self.userDefaults doubleForKey:kLocationLongitudeKey];
	currentLocation.latitude	= [self.userDefaults doubleForKey:kLocationLatitudeKey];

	//set up the region for the map display.  0.003 degrees was chosen as a nice size
	MKCoordinateRegion coordRegion;
	coordRegion.center = currentLocation;
	coordRegion.span.longitudeDelta = .003;
	coordRegion.span.latitudeDelta = .003;
	[self.mapView setRegion:coordRegion animated:YES];
	
	//Now create a pin at the current location
	PinAnnotation *myStartingLocationPin = [[PinAnnotation alloc] initWithCoordinate:self.currentLocation];
	//assign a title to the pin consisiting of the long, lat and altitude
	myStartingLocationPin.title	= [NSString stringWithFormat:@"%5.4f%@, %5.4f%@", 
								   fabs(currentLocation.latitude), 
								   (currentLocation.latitude >= 0 ? @"N" : @"S"),
								   fabs(currentLocation.longitude),
								   (currentLocation.longitude >= 0 ? @"E" : @"W")];
	myStartingLocationPin.subtitle = [NSString stringWithFormat:@"%5.1fmeters", [self.userDefaults doubleForKey:kLocationAltitudeKey]];
	//add the pin to the map
	[mapView addAnnotation:myStartingLocationPin];
	[myStartingLocationPin release];

	//set the long and lat and alt text in the text boxes
	self.longitude.text = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.longitude),
						   (currentLocation.longitude >= 0 ? @"E" : @"W")];
	self.latitude.text  = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.latitude),
						   (currentLocation.latitude >= 0 ? @"N" : @"S")];
	double alt = [self.userDefaults doubleForKey:kLocationAltitudeKey];
	self.altitude.text	=   ((alt == 0.0 || alt == 32.1) ? NSLocalizedString(@"unknown", @"Unknown Altitude"):[NSString stringWithFormat:@"%5.0f meters", alt]);
	self.textLocation.text = [userDefaults objectForKey:kLocationNameKey];
	
	//initialize the location manager and tell it we want the best accuracy.
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	
	//Add the "Locations" button to the navigation bar
	UIBarButtonItem  *locationsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Locations", @"Location")
																		 style:UIBarButtonItemStyleBordered 
																		target:self 
																		action:@selector(locations)];
    self.navigationItem.rightBarButtonItem = locationsButton;
	UIColor *toolbarColor = kNavBarColor;
	self.toolbar.tintColor = toolbarColor;
//	self.mapType.tintColor = toolbarColor;
//	self.mapType.tintColor = kMapControlColor;
	self.mapType.momentary = NO;
	[locationsButton release];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {//! \private
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

/**
 When the view unloads tell the location manager to stop updating
 */

- (void)viewDidUnload {//! \private
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[locationManager stopUpdatingLocation];
}

/**
 @brief Update the view information when the view appears
 
 Anytime the view reappears the current location, map and pin need to be update similar to view did load.  This typically 
 occurs when returning from the location list with a newly selected location.
 */

- (void)viewWillAppear:(BOOL)animated{//! \private
	currentLocation.longitude = [self.userDefaults doubleForKey:kLocationLongitudeKey];
	currentLocation.latitude	= [self.userDefaults doubleForKey:kLocationLatitudeKey];
	self.longitude.text = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.longitude),
						   (currentLocation.longitude >= 0 ? @"E" : @"W")];
	self.latitude.text  = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.latitude),
						   (currentLocation.latitude >= 0 ? @"N" : @"S")];
	double alt = [self.userDefaults doubleForKey:kLocationAltitudeKey];
	self.altitude.text	=   ((alt == 0.0 || alt == 32.1) ? NSLocalizedString(@"unknown", @"Unknown Altitude"):[NSString stringWithFormat:@"%5.0f meters", alt]);
	self.textLocation.text = [userDefaults objectForKey:kLocationNameKey];
	MKCoordinateRegion coordRegion;
	coordRegion.center = currentLocation;
	coordRegion.span.longitudeDelta = .003;
	coordRegion.span.latitudeDelta = .003;

	[self.mapView setRegion:coordRegion animated:YES];
	PinAnnotation *myStartingLocationPin = [[PinAnnotation alloc] initWithCoordinate:self.currentLocation];
	myStartingLocationPin.title	= [NSString stringWithFormat:@"%5.4f%@, %5.4f%@", 
								   fabs(currentLocation.latitude), 
								   (currentLocation.latitude >= 0 ? @"N" : @"S"),
								   fabs(currentLocation.longitude),
								   (currentLocation.longitude >= 0 ? @"E" : @"W")];
	myStartingLocationPin.subtitle = [NSString stringWithFormat:@"%5.1fmeters", [self.userDefaults doubleForKey:kLocationAltitudeKey]];
	[mapView addAnnotation:myStartingLocationPin];
	[myStartingLocationPin release];
	
	
	[super viewWillAppear:animated];
}

/**
 @brief cleans up when the view goes off screen
 
 Stops the location mananger from updating and cancels any reverse geocoding which may be in progress.
 */

- (void)viewDidDisappear:(BOOL)animated{//! \private
	[locationManager stopUpdatingLocation];
	[reverseGeocoder cancel];
	[super viewDidDisappear:animated];
}

/**
 @brief Called when the location icon button is touched
 
 Handles the toggling of the location button.  If it is not active, the button will be 
 toggled to turn blue and the location manager is told to start updating the location.  
 If the button is active it is made inactive and the locaiton manager is told to stop
 updating the location.
 
 Finally, a refresh notification is posted so that the EventListController and BookMarkListController
 know to update their table displays, possibly changing the status colors of some items and displaying
 some objects which were previously below the minimun altitude.
 */

-(IBAction)updateLocation:(id)sender{//! \private
		self.mapView.showsUserLocation = YES;
	if ([(UIBarButtonItem *)sender style] ==UIBarButtonItemStyleDone){
//		[(UIBarButtonItem *)sender setTitle:@"Stop" ];
		[sender setImage:[UIImage imageNamed:@"LocationButton.png"]];

		[(UIBarButtonItem *)sender setStyle:UIBarButtonItemStyleBordered];
		[locationManager stopUpdatingLocation];		
	}else{
//		[(UIBarButtonItem *)sender setTitle:@"Update"];

		[sender setImage:[UIImage imageNamed:@"LocationButtonOn.png"]];

		[(UIBarButtonItem *)sender setStyle:UIBarButtonItemStyleDone];
		[locationManager startUpdatingLocation];	
		[reverseGeocoder cancel];
	}
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:self]];

}

/**
 @brief Changes the type of map displayed when the user touches the map type control
 */

-(IBAction)mapTypeChanged:(id)sender{//! \private
	NSInteger mapTypeIndex;
	mapTypeIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
	switch (mapTypeIndex) {
		case kMap:
			[self.mapView setMapType:MKMapTypeStandard];
			break;
		case kSatellite:
			[self.mapView setMapType:MKMapTypeSatellite];
			break;
		case kHybrid:
			[self.mapView setMapType:MKMapTypeHybrid];
			break;
		default:
			break;
	}
}

/**
 @brief Called when the user presses the "+" button on the bottom toolbar
 
 Displays an action sheet confirming that the user actually wants to add this location to their location list.
 When the user makes a selection actionSheet:clickedButtonAtIndex: is called.
 */

-(IBAction)addToLocations:(id)sender{//! \private

	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to add this location to your location list?", @"Add New Location Title" )
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
										 destructiveButtonTitle:nil
											  otherButtonTitles:nil];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Add To Location List", @"Add To Location List Button Title")];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromToolbar:self.toolbar];
	[actionSheet release];
}

/**
 @brief Called when the addToLocations action sheet is dismissed by making a selection of one of the buttons.
 */

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{//! \private
	if (buttonIndex == 1) { //The user confirmed that the location is to be added to the location database.
		//get the managed object context since the location list is stored in CoreData
		NSManagedObjectContext *managedObjectContext = [[[UIApplication sharedApplication] delegate] managedObjectContext];
		//create a new entity in the database and get a pointer to the entity.
		Locations *location = (Locations *)[NSEntityDescription insertNewObjectForEntityForName:@"Locations"
																		 inManagedObjectContext:managedObjectContext];
		//populate the fields of the location entity.
		location.Altitude = [NSNumber numberWithDouble:[self.altitude.text doubleValue]];
		location.Longitude = [NSNumber numberWithDouble:[userDefaults doubleForKey:kLocationLongitudeKey]];
		location.Latitude = [NSNumber numberWithDouble:[userDefaults doubleForKey:kLocationLatitudeKey]];
		location.Name = [userDefaults objectForKey:kLocationNameKey];
		//The section name is simply the first letter of the name
		location.SectionName = [location.Name substringToIndex:1];
		
		//Save the changed managed object and handle the error if necessary.
		NSError *error = nil;
		if (![managedObjectContext save:&error]){
			NSLog(@"Unable to save new location:%@",[error localizedDescription]);
		}
		
		
	}
}

/**
 @brief Displays the locations list when the user touches the "Locations" button
 
 Instatiates the LocationListController object and pushes it onto the navigation stack hiding the bottom bar. 
 */

- (void)locations{//! \private
	LocationListController *nextView = [[LocationListController alloc] init];
	nextView.hidesBottomBarWhenPushed = YES;
	[self.navController pushViewController:nextView animated:YES];
	[nextView release];
	
	
}

/**
 @brief Updates the location display when the user completes the editing of longitude or latitude or 
 the locationManager gets a new location.
 
 Reads the new coordinates from the text box, updates the map, the annotation pin (if showPin is YES), the location name
 and stores the updated information in the userDefaults database.
 
 showPin should be yes if a red annotation pin is to be placed at the new location.  This is done when the new location
 has been hand edited.  If the new location is from the location manager, the location manager will automatically place 
 a blue pin at the new location.
 */

- (void)didUpdateToLocation:(CLLocation *)newLocation showPin:(BOOL)showPin{//! \private
	double mapsize;
	//get the new location from the text boxes.
	currentLocation.longitude = newLocation.coordinate.longitude;
	currentLocation.latitude	= newLocation.coordinate.latitude;
	//set the map size
	mapsize = (newLocation.horizontalAccuracy/kEarthCircumference)*360.0*5.0;
	
	//Set the coordinate data structure
	MKCoordinateRegion coordRegion;
	coordRegion.center = currentLocation;
	coordRegion.span.longitudeDelta = mapsize;
	coordRegion.span.latitudeDelta = mapsize;
	//Tell the map view the new coordinates
	[self.mapView setRegion:coordRegion animated:YES];
	if (showPin) {
		PinAnnotation *myStartingLocationPin = [[PinAnnotation alloc] initWithCoordinate:self.currentLocation];
		myStartingLocationPin.title	= [NSString stringWithFormat:@"%5.4f%@, %5.4f%@", 
									   fabs(currentLocation.latitude), 
									   (currentLocation.latitude >= 0 ? @"N" : @"S"),
									   fabs(currentLocation.longitude),
									   (currentLocation.longitude >= 0 ? @"E" : @"W")];
		myStartingLocationPin.subtitle = [NSString stringWithFormat:@"%5.1fmeters", [self.userDefaults doubleForKey:kLocationAltitudeKey]];
		[mapView addAnnotation:myStartingLocationPin];
		[myStartingLocationPin release];
		
	}
	//Create a pin at this new location
	
	//update the user defaults with the new coordinate information
	[userDefaults setFloat:currentLocation.longitude forKey:kLocationLongitudeKey];
	[userDefaults setFloat:currentLocation.latitude forKey:kLocationLatitudeKey];
	[userDefaults setFloat:newLocation.altitude forKey:kLocationAltitudeKey];
	self.longitude.text = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.longitude),
						   (currentLocation.longitude >= 0 ? @"E" : @"W")];
	self.latitude.text  = [NSString stringWithFormat:@"%5.4f%@", 
						   fabs(currentLocation.latitude),
						   (currentLocation.latitude >= 0 ? @"N" : @"S")];
	double alt = [self.userDefaults doubleForKey:kLocationAltitudeKey];
	self.altitude.text	=   ((alt == 0.0 || alt == 32.1) ? NSLocalizedString(@"unknown", @"Unknown Altitude"):[NSString stringWithFormat:@"%5.0f meters", alt]);
	//start a new reverseGeocoder search.  First, we will release any existing reverse geocoder object.
	[reverseGeocoder release];
	//set the reverse geocoder to nil. Always a good idea after releasing, that way if an attempt is made to release the object
	//again without initializing it, nothing bad will happen.  This is because in ObjC you can send any message to nil and not 
	//generate an error.
	self.reverseGeocoder = nil;
	self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:currentLocation];
	self.reverseGeocoder.delegate = self;
	[self.reverseGeocoder start];
}

- (void)dealloc {//! \private
	[locationManager release];
	[reverseGeocoder cancel];
	[reverseGeocoder release];
    [super dealloc];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
/**
 @brief Callback for the location manager when it gets a new location
 
 When the location manager is told to start updating location it will call back to this method
 any time it gets a new and better location.  This method could be called multiple times, hopefully with 
 increasing better location accuracy.  Each time this method is called the new locations are extracted
 and passed to didUpdateToLocation:showPin.  The new location's horizontal accuracy is used to update the size
 of the map causing the map to zoom in as the accuracy improves.
 

 
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
	fromLocation:(CLLocation *)oldLocation{//! \private

	[self didUpdateToLocation:newLocation showPin:NO];
}


#pragma mark -
#pragma mark ReverseGeocoderDelegate

/**
 @brief Callback delegate for the reversGeocoder when it finds information for the new coordinates
 
 The callback extracts the address of the coordinate and updates the location display text as well
 as the userDefaults database.
 
 */

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{//! \private
	NSString *locationString = [[NSString alloc] initWithFormat:@"%@%@%@  %@", 
								(placemark.locality ? placemark.locality : @""), 
								(placemark.locality ? @", " : @""),
								(placemark.administrativeArea ? placemark.administrativeArea : @""), 
								(placemark.postalCode ? placemark.postalCode : @"")];
	self.textLocation.text = locationString;
	[userDefaults setObject:locationString forKey:kLocationNameKey];
	[locationString release];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{//! \private
	self.textLocation.text = NSLocalizedString(@"Unknown Location", @"Unknown Location");
	
}

#pragma mark -
#pragma mark UITextFieldDelegate

/**
 @brief Callback when the Done button is pressed after editing a text field
 
 Dismisses the keyboard and the checks to see if the location fields were editied.  If the location fields
 were changed then we call didUpdateToLocation:showPin with the new location coordinates.
 */

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {//! \private
	//Dismiss the keyboard
	[theTextField resignFirstResponder];
	//Handle a change in coordinates
	if(theTextField == latitude || theTextField == longitude || theTextField == altitude){
		double newLongitude, newLatitude;
		//get the new coordinates
		//first get the numbers
		newLatitude = [latitude.text doubleValue];
		newLongitude = [longitude.text doubleValue];
		//See what the suffix is and swap sign if necessary
		if ([latitude.text hasSuffix:@"S"] || [latitude.text hasSuffix:@"s"]) newLatitude = -newLatitude;
		if ([longitude.text hasSuffix:@"W"] || [longitude.text hasSuffix:@"w"]) newLongitude = -newLongitude;
		//put the coordinates in the data structure
		CLLocationCoordinate2D newLocationCoord;
		newLocationCoord.longitude = newLongitude;
		newLocationCoord.latitude = newLatitude;
		CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:newLocationCoord 
																altitude:[altitude.text doubleValue] 
													  horizontalAccuracy:100 
														verticalAccuracy:100 
															   timestamp:[NSDate date]];
		//update the map display
		[self didUpdateToLocation:newLocation showPin:YES];
		[newLocation release];

	}
	//If the location name was changed update userDefaults
	if (theTextField == textLocation){
		[userDefaults setObject:textLocation.text forKey:kLocationNameKey];
	}
	return YES;
}


@end
