//
//  LocationSettingViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/2/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

/**
 @brief Displays the location coordinates and a map/satelite view of the location.
 
 Inherits from UIViewController
 
 The LocationSettingViewController displays the current location settings for the app.  
 The view is accessed by touching the location coordinates in the settings view. The 
 display of the locaiton includes longitude, latitude and altitude as well as the name
 of the location and a red pin at the current coordinates.  The user can update the current location in three ways.
 
 -# type in new longitude and latitude coordinates. Altitude and name are optional, the name 
 will be filled in automatically if it can be found in the geocoordinates database.
 -# Touch the current location button at the far left of the lower toolbar
 -# Touch the Locations button on the right side of the navigation bar and then select a location 
 from the list.
 
 When a location is entered either by option 1 or 2 the object will attempt to look up the location
 in the reverse geocoder database (network connection required).  If it is found the address
 of the location will be automatically entered in the location field.  The user can override this 
 entry with their own descriptive name if desired.
 
 The user has the option of displaying the location as a map, a satellite view or a hybrid view.
 
 There is a '+' sign at the right side of the bottom toolbar which allows the user to add the current location to
 the location list database.
 
 
 */


@interface LocationSettingViewController : UIViewController <UIActionSheetDelegate,
		CLLocationManagerDelegate,MKReverseGeocoderDelegate> {
	
	IBOutlet	MKMapView	*mapView;
	IBOutlet	UITextField		*longitude;
	IBOutlet	UITextField		*latitude;
	IBOutlet	UITextField		*textLocation;
	IBOutlet	UITextField		*altitude;
	IBOutlet	UISegmentedControl *mapType;
			IBOutlet	UIToolbar		*toolbar;
			IBOutlet	UIView			*tintView;
			IBOutlet	UISegmentedControl *mapControl;
	MKReverseGeocoder		*reverseGeocoder;
	
	CLLocationManager		*locationManager;
	
	CLLocationCoordinate2D	currentLocation;
	NSUserDefaults			*userDefaults;
	
	UINavigationController  *navController;
}

@property (nonatomic, retain)	MKMapView	*mapView; //!< pointer to the map view in the XIB
@property (nonatomic, retain)	UITextField		*longitude; //!< pointer to the longitude text edit field in the XIB
@property (nonatomic, retain)	UITextField		*latitude; //!< pointer to the latitude text edit field in the XIB
@property (nonatomic, retain)	UITextField		*textLocation; //!< pointer to the text location name edit field in the XIB
@property (assign)				CLLocationCoordinate2D	currentLocation; //!< the current 2D location coordinates
@property (nonatomic, retain)	NSUserDefaults *userDefaults; //!< pointer to the userDefaults database
@property (nonatomic, retain)	CLLocationManager *locationManager; //!< pointer to the location manager
@property (nonatomic, retain)	UITextField		*altitude; //!< pointer to the atitude text field  in the XIB
@property (nonatomic, retain)	UISegmentedControl *mapType; //!< pointer to the segmented control used to select the map type  in the XIB
@property (nonatomic, retain)	MKReverseGeocoder *reverseGeocoder; //!< pointer to the reverse geocoder object
@property (nonatomic, retain)	UINavigationController  *navController; //!< pointer to the navigation controller so more objects can be pushed onto the navigation stack
@property (nonatomic, retain) 	UIToolbar		*toolbar; //!< pointer to the bottom toolbar in the XIB
@property (nonatomic, retain)	UIView			*tintView; //!< pointer to view used to tint background
@property (nonatomic, retain) 	IBOutlet	UISegmentedControl *mapControl; //!pointer to map type control
	
-(IBAction)updateLocation:(id)sender; //!< \private
-(IBAction)mapTypeChanged:(id)sender;//!< \private
-(IBAction)addToLocations:(id)sender;//!< \private

@end
