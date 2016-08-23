//
//  BookmarkDetailController.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/10/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Transient;

/**
 @brief Displays the details of bookmarked items.
 
 This object is identical in appearance to Event Detail Controller
 but rather than pulling data from the JSON created dictionary it pulls data from
 a Transient object which is passed in from the Bookmark List Controller
 
 After initialization the calling object must set the transient property to
 the transient event to be displayed.
 
*/

@interface BookmarkDetailController : UIViewController
	<UIActionSheetDelegate, UIScrollViewDelegate, 
	MFMailComposeViewControllerDelegate>{
		IBOutlet UILabel		*airmass;
		IBOutlet UILabel		*alertTime;
		IBOutlet UILabel		*azAltCoordinates;
		IBOutlet UILabel		*coordinates;
		IBOutlet UILabel		*eventID;
		IBOutlet UILabel		*eventTime;
		IBOutlet UIImageView	*imageDisplay;
		IBOutlet UILabel		*magnitude;
		IBOutlet UILabel		*attribution;
		IBOutlet UIToolbar		*toolbar;
		IBOutlet UIScrollView	*scrollView;
		IBOutlet UIPageControl	*pageControl;
		IBOutlet UIButton		*nextButton;
		IBOutlet UIButton		*previousButton;
		IBOutlet UIImageView	*backgroundView;
		IBOutlet UIButton	*streamIconLeft;
		IBOutlet UIButton	*streamIconRight;
        
        IBOutlet UIView     *leftUIView;
        IBOutlet UIView     *rightUIView;
		
        
        IBOutlet UIImageView    *iPadImage1;
        IBOutlet UIImageView    *iPadImage2;
        IBOutlet UIImageView    *iPadImage3;
        IBOutlet UIImageView    *iPadImage4;
        IBOutlet UIImageView    *iPadImage5;
        IBOutlet UILabel        *iPadImageLabel1;
        IBOutlet UILabel        *iPadImageLabel2;
        IBOutlet UILabel        *iPadImageLabel3;
        IBOutlet UILabel        *iPadImageLabel4;
        IBOutlet UILabel        *iPadImageLabel5;
        IBOutlet UILabel        *iPadEventType;
        IBOutlet UITextView   *iPadInfoTextView;
        
		
		Transient				*transient;
		
		BOOL					pageControlUsed;
		

		
		NSUserDefaults		*userDefaults;

		IBOutlet UILabel		*imageDescription;		


	
}
@property (nonatomic, retain) UIImageView *iPadImage1;
@property (nonatomic, retain) UIImageView *iPadImage2;
@property (nonatomic, retain) UIImageView *iPadImage3;
@property (nonatomic, retain) UIImageView *iPadImage4;
@property (nonatomic, retain) UIImageView *iPadImage5;
@property (nonatomic, retain) UILabel     *iPadImageLabel1;
@property (nonatomic, retain) UILabel     *iPadImageLabel2;
@property (nonatomic, retain) UILabel     *iPadImageLabel3;
@property (nonatomic, retain) UILabel     *iPadImageLabel4;
@property (nonatomic, retain) UILabel     *iPadImageLabel5;
@property (nonatomic, retain) UILabel     *iPadEventType;
@property (nonatomic, retain) UITextView *iPadInfoTextView;
@property (nonatomic, retain) NSMutableArray   *iPadImages;
@property (nonatomic, retain) NSMutableArray   *iPadImageLabels;
@property (nonatomic, retain) UIImageView	*backgroundView;	
@property (nonatomic, retain) UIButton	*streamIconLeft;
@property (nonatomic, retain) UIButton	*streamIconRight;
@property (nonatomic, retain) UILabel *airmass;
@property (nonatomic, retain) UILabel *alertTime;
@property (nonatomic, retain) UILabel *azAltCoordinates;
@property (nonatomic, retain) UILabel *coordinates;
@property (nonatomic, retain) UILabel *eventID;
@property (nonatomic, retain) UILabel *eventTime;
@property (nonatomic, retain) UIImageView *imageDisplay;
@property (nonatomic, retain) UILabel *magnitude;
@property (nonatomic, retain) UILabel *attribution;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIScrollView	*scrollView;	
@property (nonatomic, retain) UIPageControl	*pageControl;	

@property (nonatomic, retain) 	UILabel		*imageDescription;
@property (nonatomic, retain) 	UIButton		*nextButton;
@property (nonatomic, retain) 	UIButton		*previousButton;

@property (nonatomic, retain) UIView *leftUIView;
@property (nonatomic, retain) UIView *rightUIView;


@property (nonatomic, retain) Transient	*transient; //!< object to be displayed.



- (IBAction)displayFinderChart:(id)sender;//!< \private
- (IBAction)emailEvent:(id)sender; //!< \private
- (IBAction)changePage:(id)sender; //!< \private
- (void)fillInEventData;//!< \private
- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;
- (void)setScrollArrowStatus; //!< \private
@end
