//
//  SurveyQuestion2ViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SurveyQuestion2ViewController : UIViewController {
	UINavigationController *navController;	 //!< Contains the navigation controller
	
	UIButton	*selectedButton;
	IBOutlet UIButton	*nextButton;
	NSMutableDictionary *surveyResults;
	IBOutlet	UIView		*tintView;
	
	
}
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) NSMutableDictionary *surveyResults;
@property (nonatomic, retain) 	UIView		*tintView;//!< view to tint background

- (IBAction)buttonPressed:(id)sender; 
- (IBAction)nextButtonPressed;

@end
