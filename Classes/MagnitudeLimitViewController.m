//
//  MagnitudeLimitViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "MagnitudeLimitViewController.h"
#import "Constants.h"



@implementation MagnitudeLimitViewController
@synthesize	minValue;
@synthesize	maxValue;
@synthesize	limitingMagnitude;
@synthesize	magnitudeSlider;
@synthesize	userDefaults;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Magnitude Limit", @"Magnitude Limit Page Title");
    }
    return self;
}


/**
 Gets the pointer to standard user defaults and the sets the min, max and current version of the
 slider and associated labled.
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	userDefaults = [NSUserDefaults standardUserDefaults];
	minValue.text = [NSString stringWithFormat:@"%3.1f",[userDefaults floatForKey:kLimitingMagnitudeLowerLimitKey]];
	maxValue.text = [NSString stringWithFormat:@"%3.1f",[userDefaults floatForKey:kLimitingMagnitudeUpperLimitKey]];
	limitingMagnitude.text = [NSString stringWithFormat:@"%3.1f",[userDefaults floatForKey:kLimitingMagnitudeKey]];
	magnitudeSlider.minimumValue = [userDefaults floatForKey:kLimitingMagnitudeUpperLimitKey];
	magnitudeSlider.maximumValue = [userDefaults floatForKey:kLimitingMagnitudeLowerLimitKey];
	magnitudeSlider.value = [userDefaults floatForKey:kLimitingMagnitudeKey];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/**
 Reads the new slider value and rounds it to the nearest 0.1 magnitude.  The value is
 then set in user defaults.
 
 Finally sends the kReloadNotification which tells the EventListController that it must reload
 data from the server.
 
 */
- (IBAction)sliderValueChanged:(id)sender{
	float newValue;
	newValue = [(UISlider *)sender value];
	newValue = ((int)(newValue * 10.0))/10.0;
	[userDefaults setFloat:newValue forKey:kLimitingMagnitudeKey];
	limitingMagnitude.text = [NSString stringWithFormat:@"%3.1f",[userDefaults floatForKey:kLimitingMagnitudeKey]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kReloadNotification object:self]];
}

- (void)dealloc {
    [super dealloc];
}


@end
