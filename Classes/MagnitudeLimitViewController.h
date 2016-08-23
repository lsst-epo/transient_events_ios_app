//
//  MagnitudeLimitViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief UIViewController which handles the magnitude limit slider
 
 Inherits from UIViewController
 */

@interface MagnitudeLimitViewController : UIViewController {
	IBOutlet	UILabel		*minValue;			//!< Label for minimum slider value
	IBOutlet	UILabel		*maxValue;//!< Label for maximum slider value
	IBOutlet	UILabel		*limitingMagnitude;//!< Label which displays the current magnitued setting
	IBOutlet	UISlider	*magnitudeSlider;//!< Pointer to the slider
	NSUserDefaults	*userDefaults;//!< Pointer to the Standard User Defaults
}

@property(nonatomic, retain)	UILabel		*minValue;			//!< Label for minimum slider value
@property(nonatomic, retain)	UILabel		*maxValue;			//!< Label for maximum slider value
@property(nonatomic, retain)	UILabel		*limitingMagnitude; //!< Label which displays the current magnitued setting
@property(nonatomic, retain)	UISlider	*magnitudeSlider;	//!< Pointer to the slider
@property(nonatomic, retain)	NSUserDefaults	*userDefaults;	//!< Pointer to the Standard User Defaults


- (IBAction)sliderValueChanged:(id)sender; //!< Action called when the slider changes

@end
