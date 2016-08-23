//
//  EventDetailController.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/10/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


/**
 @brief Displays events from the event list
 
 The EventDetailController is used to display generic transient event details.  These
 events have a reference image URL and four recent image URLs, finder page URL, RA, Dec, magnitude and alert time
 contained in the object dictionary passed to the controller.
 
 The images can be viewed by swiping them left and right as well as using the left and right arrows or the page 
 controller.  Images are loaded using the same ImageLoadingOperation used by the EventListController.
 
 If the user wants to send info about the event to another person they can press the compose button and the 
 controller will call up the email controller and populate the email with event details and two of the images.
 
 If this event is of interest and the user wants to save it, pressing the + button will add it to the bookmarks 
 CoreData store where it can be viewed off line on the Bookmarks page. The details are are populated from the
 existing object dictionary.  Since all of the images may not be downloaded they are all downloaded again  This may
 seem inefficient but it is simple and the data downloads reasonably quickly (except on a slow EDGE connection).
 The process is done in the background so you can still press other buttons but they may not do anything until the
 download is complete.  This is not quite true, you can flip the images, send an email or go to the finder chart.  
 You cannot go back to the list view, the button is hidden.  To give the user an idea that something is going on
 in the background a progress bar is use to display the download progress.  It is incremented after each image 
 download is complete by calling a method on the main thread.
 
 The finder chart can be viewed by pressing the FinderChart button.  This will push a UIWebView based page onto the
 nav Controller stack and pass it the URL of the finder page.
 
 */


@interface EventDetailController : UIViewController<UIActionSheetDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>{
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
		IBOutlet UILabel		*imageDescription;
		IBOutlet UIProgressView *progressBar;
		IBOutlet UIBarButtonItem *plusButton;
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
    
    
    //		NSMutableDictionary		*imageDictionary;
		BOOL					pageControlUsed;
		
		NSDictionary			*eventDetails;
//		NSArray					*imageKeys;
		NSMutableDictionary *cachedImages;
		NSMutableDictionary *cachedImageStatus;
		
		NSMutableArray *photoURLs;
		NSOperationQueue *operationQueue;
		NSUserDefaults		*userDefaults;
		BOOL	bookmarkThreadRunning;

		


	
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
//@property (nonatomic, retain) NSMutableDictionary		*imageDictionary;
@property (nonatomic, retain) UIScrollView	*scrollView;	
@property (nonatomic, retain) UIPageControl	*pageControl;	
@property (nonatomic, retain) NSDictionary *eventDetails;
@property (nonatomic, retain) 	NSMutableDictionary *cachedImages;
@property (nonatomic, retain) 	NSMutableArray *photoURLs;
@property (nonatomic, retain)	NSMutableDictionary *cachedImageStatus;
@property (nonatomic, retain) 	UIButton		*nextButton;
@property (nonatomic, retain) 	UIButton		*previousButton;
@property (nonatomic, retain) 	UILabel		*imageDescription;
@property (nonatomic, retain) 	UIProgressView *progressBar;
@property (nonatomic, retain) 	UIBarButtonItem *plusButton;
@property (nonatomic, retain) UIView *leftUIView;
@property (nonatomic, retain) UIView *rightUIView;


- (IBAction)objInfo:(id)sender; // Oject info button on toolbar

- (IBAction)addBookmark:(id)sender; //!< Adds the current event to the bookmark database
- (IBAction)displayFinderChart:(id)sender;//!< Displays the finder chart for the object based on the URL provided in the data stream
- (IBAction)emailEvent:(id)sender; //!< Creates an email with the event data, the reference image and the first new image
- (IBAction)nextImage:(id)sender; //!< Moves to the next image - used by the right arrow button
- (IBAction)previousImage:(id)sender; //!< Moves to the previous image - used by the left arrow button
- (IBAction)changePage:(id)sender; //!< Changes the image based on the action of the page controller
- (void)fillInEventData; //!< Fills in the text field data
- (UIImage *)cachedImageForURL:(NSURL *)url; //!< Gets the image pointed to by the URL. 
- (void)didFinishLoadingImageWithResult:(NSDictionary *)result; //!< Callback once image is loaded
- (void)setScrollArrowStatus; //!< Enables and disables image scroll buttons depending on which image is visible
- (void)incrementProgressBar:(NSNumber *)progress; //!< Sets the the progress bar shown when loading bookmarks
- (void)addTransientDataToCoreDataStore; //!< Adds the current object to the Core Data bookmark store
@end
