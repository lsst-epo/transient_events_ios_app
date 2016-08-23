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
		IBOutlet UIImageView	*streamIconLeft;
		IBOutlet UIImageView	*streamIconRight;
		
		
		Transient				*transient;
		
		BOOL					pageControlUsed;
		

		
		NSUserDefaults		*userDefaults;

		IBOutlet UILabel		*imageDescription;		


	
}
@property (nonatomic, retain) UIImageView	*backgroundView;	
@property (nonatomic, retain) UIImageView	*streamIconLeft;
@property (nonatomic, retain) UIImageView	*streamIconRight;
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

@property (nonatomic, retain) Transient	*transient; //!< object to be displayed.



- (IBAction)displayFinderChart:(id)sender;//!< \private
- (IBAction)emailEvent:(id)sender; //!< \private
- (IBAction)changePage:(id)sender; //!< \private
- (void)fillInEventData;//!< \private
- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;
- (void)setScrollArrowStatus; //!< \private
@end
