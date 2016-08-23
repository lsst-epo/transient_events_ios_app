//
//  MinimumAltitudeViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 10/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays the minimum altitude selection slider
 
 Inherits from UIViewController
 
 The MinimumAltitudeViewController displays the slider which allows the user to set the minimum
 altitude of events to be displayed.  This is done using a UISLider.  The selected altitude is stored
 in the userDefaults database.
 */

@interface MinimumAltitudeViewController : UIViewController {
	IBOutlet	UILabel		*minValue;
	IBOutlet	UILabel		*maxValue;
	IBOutlet	UILabel		*minAltitude;
	IBOutlet	UISlider	*altitudeSlider;
	
	NSUserDefaults	*userDefaults;
	
}

@property(nonatomic, retain)	UILabel		*minValue; //!< pointer to the label for the minimum value in the XIB
@property(nonatomic, retain)	UILabel		*maxValue;//!< pointer to the label for the maximum value in the XIB
@property(nonatomic, retain)	UILabel		*minAltitude; //!< pointer to the label for the current minimum altitude slider setting in the XIB
@property(nonatomic, retain)	UISlider	*altitudeSlider;//!< pointer to the slider in the XIB
@property(nonatomic, retain)	NSUserDefaults	*userDefaults;//!< pointer to the userDefaults database

- (IBAction)sliderValueChanged:(id)sender; //!< \private

@end
