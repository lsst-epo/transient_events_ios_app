//
//  SurveyQuestion3ViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SurveyQuestion3ViewController : UIViewController <UITextViewDelegate>{

	NSMutableDictionary *surveyResults;
	IBOutlet	UIView		*tintView;
	IBOutlet	UITextView *scrollView;
	
	
}
@property (nonatomic, retain) NSMutableDictionary *surveyResults;
@property (nonatomic, retain) 	UIView		*tintView;//!< view to tint background
@property (nonatomic, retain) UITextView	*scrollView;

- (void)doneButtonPressed;
- (void)sendSurveyResultsSynchronously:(BOOL)synchronous;

@end
