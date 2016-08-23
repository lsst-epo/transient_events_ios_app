//
//  SurveyQuestion1ViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SurveyQuestion1ViewController : UIViewController {
	UINavigationController *navController;	 //!< Contains the navigation controller

	UIButton	*selectedButton;
	IBOutlet UIButton	*nextButton;
	NSMutableDictionary *surveyResults;
	IBOutlet	UIView		*tintView;
	UITabBarController		*tabBarController;
	

}
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UIButton *selectedButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) NSMutableDictionary *surveyResults;
@property (nonatomic, retain) 	UIView		*tintView;//!< view to tint background
@property (nonatomic, retain) 	UITabBarController *tabBarController;

- (IBAction)buttonPressed:(id)sender; 
- (IBAction)nextButtonPressed;

@end
