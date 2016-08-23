//
//  MinimumAltitudeViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 10/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "MinimumAltitudeViewController.h"
#import "Constants.h"


@implementation MinimumAltitudeViewController
@synthesize	minValue;
@synthesize	maxValue;
@synthesize	minAltitude;
@synthesize	altitudeSlider;
@synthesize userDefaults;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Minimum Altitude", @"Minimum Altitude Page Title");
    }
    return self;
}


/**
 Reads the min, max and current values from the userDefaults database and sets them in the view.
 */
- (void)viewDidLoad {//! \private
	//get the pointer to the user defaults database
	userDefaults = [NSUserDefaults standardUserDefaults];
	//set the minimum and maximum slider values based on values in the database
	altitudeSlider.minimumValue = [userDefaults floatForKey:kMinimumAltitudeLowerLimitKey];
	altitudeSlider.maximumValue = [userDefaults floatForKey:kMinimumAltitudeUpperLimitKey];
	//set the current minimum value
	altitudeSlider.value = [userDefaults floatForKey:kMinAltitudeKey];
	//set the min, max and current value labels
	minValue.text = [NSString stringWithFormat:@"%3.0f˚",[userDefaults floatForKey:kMinimumAltitudeLowerLimitKey]];
	maxValue.text = [NSString stringWithFormat:@"%3.0f˚",[userDefaults floatForKey:kMinimumAltitudeUpperLimitKey]];
	minAltitude.text = [NSString stringWithFormat:@"%d˚",[userDefaults integerForKey:kMinAltitudeKey]];
	
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

- (void)viewDidUnload {//! \private
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
/**
 When the slider value changes this method is called.  It reads the new value from the slider,
 updates the userDefaults database and updates the text in the view which displays the current value.  
 
 Finally it posts a kReloadNotification telling the eventListView to reload from the server.
 */
- (IBAction)sliderValueChanged:(id)sender{//! \private
	float newValue;
	//get the value from the slider
	newValue = (int) [(UISlider *)sender value];
	//update the value in userDefaults
	[userDefaults setInteger:newValue forKey:kMinAltitudeKey];
	//update the display text
	minAltitude.text = [NSString stringWithFormat:@"%d˚",[userDefaults integerForKey:kMinAltitudeKey]];
	//post the reload needed notification
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kReloadNotification object:self]];

}


- (void)dealloc {//! \private
    [super dealloc];
}


@end
