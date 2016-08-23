//
//  EventAgeViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "EventAgeViewController.h"
#import "Constants.h"


@implementation EventAgeViewController

@synthesize	pickerView;
@synthesize	userDefaults;



 /** The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
*/
  - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Event Age", @"Event Age Page Title");
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {//! \private
	userDefaults = [NSUserDefaults standardUserDefaults];
//	UIColor *navBarColor = kNavBarColor;
//	self.pickerView.alpha = 1.0;
//	self.pickerView.backgroundColor=navBarColor;

    [super viewDidLoad];
}

/**
 Sets the picker to the current event age stored in userDefaults
 */
- (void)viewWillAppear:(BOOL)animated{//! \private
	[pickerView selectRow:[userDefaults integerForKey:kEventAgeKey]-1 inComponent:0 animated:NO];
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


- (void)dealloc {//! \private
    [super dealloc];
}

#pragma mark -
#pragma mark UIPickerViewDataSource
/**
 Set the number of dials in the picker
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{//! \private
	return 1;
}
/**
 Sets the number of rows in each dial.  In our case it is simply the maximum age
 */

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{//! \private
	return [userDefaults integerForKey:kEventAgeMaxiumumAgeKey];
}

#pragma mark -
#pragma mark UIPickerViewDelegate
/**
 sets the width of the dial in pixels.  100 looks nice
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{//! \private
	return 100;
}

/**
 generates the label for each row in the dial.  The only tricky thing is to make 1 day singular.
 */

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{//! \private
	NSString *returnString;
	NSString *day = NSLocalizedString(@"Day", @"Singular Day");
	NSString *days = NSLocalizedString(@"Days", @"Singular Days");
	if (row == 0){
		returnString = [NSString stringWithFormat:@"%d %@",row + 1, day ];
	}else{
		returnString = [NSString stringWithFormat:@"%d %@",row + 1, days ];
	}
	return returnString;
}

/**
 Handles a selection in the picker by getting the selected row, adding 1 (since our list starts at 1)
 and the storing in userDefaults
 */
	
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{//! \private
	NSInteger newAge;
	newAge = row + 1;
	[userDefaults setInteger:newAge forKey:kEventAgeKey];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kReloadNotification object:self]];

}



@end
