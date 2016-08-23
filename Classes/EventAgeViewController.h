//
//  EventAgeViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays the Event Age selection spinner view
 
 Inherits from UIViewController
 
 The EventAgeViewController displays the spinner which allows the user to set the maximum
 age of events to be downloaded from the server.  This is done using a UIPickerView.
 */


@interface EventAgeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
	IBOutlet UIPickerView	*pickerView;
	NSTimer					*aTimer;
	
	NSUserDefaults			*userDefaults;

}

@property(nonatomic, retain)	UIPickerView	*pickerView; //!< pointer to UIPickerView
@property(nonatomic, retain)	NSUserDefaults	*userDefaults; //!<  pointer to NSUserDefaults


@end
