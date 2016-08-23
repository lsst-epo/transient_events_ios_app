//
//  BookmarkDetailController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/10/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "BookmarkDetailController.h"
#import "FinderImageViewController.h"
#import "Transient.h"
#import "Transient_EventsAppDelegate.h"
#import "Constants.h"
#import	"FinderImageWebViewController.h"
#import "AltAzComputation.h"


#define kTransitionDuration .5
#define kImageSeparation	20

//NSString *const LoadingPlaceholder = @"Loading";

@interface BookmarkDetailController (PrivateMethods)

- (void)loadScrollViewWithPages;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation BookmarkDetailController

@synthesize	airmass;
@synthesize	alertTime;
@synthesize	azAltCoordinates;
@synthesize	coordinates;
@synthesize	eventID;
@synthesize	eventTime;
@synthesize	imageDisplay;
@synthesize	magnitude;
@synthesize	attribution;
@synthesize	toolbar;
@synthesize scrollView;
@synthesize pageControl;

@synthesize imageDescription;
@synthesize	nextButton;
@synthesize	previousButton;

@synthesize	transient;
@synthesize backgroundView;
@synthesize streamIconLeft;
@synthesize streamIconRight;



/**
 @brief Designated initializer.  Call with nib "BookmarkDetailView.xib"
 
 
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		userDefaults = [NSUserDefaults standardUserDefaults];
		
		
    }
    return self;
}


/**
 @brief Sets up the email button in the toolbar and the calls fillInEventData
 and loadScrollViewWithPages.  
 
 Note that the Transient property must be set
 by the caller prior to pushing this object onto the navigation stack.  The 
 transient property must be set before this method is executed.
 
 
 */
- (void)viewDidLoad {//! \private

	UIBarButtonItem  *emailButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				target:self action:@selector(emailEvent:)];

	self.navigationItem.rightBarButtonItem = emailButton;
	UIColor *toolbarColor = kNavBarColor;
	self.toolbar.tintColor = toolbarColor;
	[self fillInEventData];
	[emailButton release];
	scrollView.contentSize = CGSizeMake((scrollView.frame.size.width) * 5,
										scrollView.frame.size.height);
	[self loadScrollViewWithPages];
	pageControl.numberOfPages = 5;
    pageControl.currentPage = 1;



    [super viewDidLoad];
}

/**
 @brief fill in all of the textual and numerical data on the screen.
 
 The method also computes the current and maximum elevation using the AltAzComputation
 object so that it can fill in the Alt and Az data
 
 
 */
- (void)fillInEventData{
	self.eventID.text = self.transient.EventID;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RAFormat" ofType:@"plist"];
	NSMutableArray *RAFormatArray = [[NSMutableArray alloc] initWithContentsOfFile:path];

	//format the RA and DEC according to the user's preference
	if ([userDefaults integerForKey:kRAFormatKey] == 0  ) {
		double RA, DEC, sec;
		NSInteger deg, hours, min;
		RA = [self.transient.RightAscension doubleValue];
		//convert to decimal hours
		RA /= 15;
		hours = (int)RA;
		RA = RA-hours;
		RA *= 60;
		min = (int)RA;
		RA = RA - min;
		sec = RA * 60.0;
		NSString *RAStr = [[NSString alloc]  initWithFormat:@"%02i:%02i:%.2f", 
							 hours, min, sec ];
		DEC = [self.transient.Declination doubleValue];
		deg = (int)DEC;
		DEC -= deg;
		DEC *=60;
		DEC = fabs(DEC);
		min = (int)DEC;
		DEC -= min;
		sec = DEC * 60.0;
		NSString *decStr = [[NSString alloc]  initWithFormat:@"%i˚ %02im %5.2fs", 
						   deg, min, sec ];
		
		self.coordinates.text = [NSString stringWithFormat:@"RA= %@  DEC= %@", RAStr, decStr];
		[RAStr release];
		[decStr release];
		
	}else {
		self.coordinates.text = [NSString stringWithFormat:@"RA= %5.6f˚  Dec= %5.6f˚", 
								 [[self.transient valueForKey:@"RightAscension"] doubleValue],
								 [[self.transient valueForKey:@"Declination"]doubleValue] ];
	}

	[RAFormatArray release];	
	self.magnitude.text = [NSString stringWithFormat:@"Mv= %5.2f",[self.transient.VisibleMagnitude floatValue]];
//	self.eventTime.text = [NSString stringWithFormat:@"Event %@",self.transient.EventDate];
	self.alertTime.text = [NSString stringWithFormat:@"Alert Time: %@",self.transient.AlertDate];
	//compute the current ALT and AZ coordinates	
	AltAzComputation *altAzCalculator = [[AltAzComputation alloc] initWithRA:[self.transient.RightAscension doubleValue]
																		 DEC:[self.transient.Declination doubleValue]];
	self.azAltCoordinates.text = [NSString stringWithFormat:@"Az= %5.5f˚ Alt= %5.5f",altAzCalculator.azimuth, altAzCalculator.altitude];;
	//compute the airmass
	self.airmass.text = 
		(altAzCalculator.altitude <=0.0 ? @"":
		 [NSString stringWithFormat:@"Airmass= %5.2f",
		  (sin(M_PI*altAzCalculator.altitude) == 0 ?9999.9:1/sin(M_PI*altAzCalculator.altitude/180.0))]);
	//	double maxAltitude = [altAzCalculator maxAltitude];
	[altAzCalculator release];
	
	self.attribution.text = self.transient.Attribution;
	NSString *imageName = [[NSString alloc] initWithFormat:@"%@Big.jpg", [self.transient valueForKey:@"EventType"]];
	UIImage *image = [UIImage imageNamed:imageName];
	if (image != nil) {
		self.backgroundView.image = image;
	}	
	[imageName release];
	if ([[self.transient valueForKey:@"EventStream"] isEqualToString:@"CRTS"]) {
		//This is a CRTS stream, display their icons
		//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	if ([[self.transient valueForKey:@"EventStream"] isEqualToString:@"CRTS2"]) {
		//This is a CRTS2 stream, display their icons
		//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	if ([[self.transient valueForKey:@"EventStream"] isEqualToString:@"CRTS3"]) {
		//This is a CRTS3 stream, display their icons
		//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	
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
- (void)viewWillAppear:(BOOL)animated{//! \private
	[super viewWillAppear:animated];
	[self changePage:self];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

/**
 @brief loads up the 5 images in the horizontal scrolling view
 
 
 */
- (void)loadScrollViewWithPages {//! \private

	
    // replace the placeholder if necessary
	CGRect frame = scrollView.frame;
	NSInteger width = frame.size.width;
	frame.origin.y = 0;
	frame.size.width = frame.size.width - kImageSeparation;
	
	frame.origin.x = width * 0 + kImageSeparation/2;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.transient.ReferenceImage] ];
	imageView.frame = frame;
	[scrollView addSubview:imageView];
	[imageView release];
	
	frame.origin.x = width * 1 + kImageSeparation/2;
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.transient.Image1] ];
	imageView.frame = frame;
	[scrollView addSubview:imageView];
	[imageView release];
	
	frame.origin.x = width * 2 + kImageSeparation/2;
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.transient.Image2] ];
	imageView.frame = frame;
	[scrollView addSubview:imageView];
	[imageView release];
	
	frame.origin.x = width * 3 + kImageSeparation/2;
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.transient.Image3] ];
	imageView.frame = frame;
	[scrollView addSubview:imageView];
	[imageView release];
	
	frame.origin.x = width * 4 + kImageSeparation/2;
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.transient.Image4] ];
	imageView.frame = frame;
	[scrollView addSubview:imageView];
	[imageView release];
	
}


/**
 @brief changes the page to the page pointed to by the value of the page control property
 
 
 */
- (IBAction)changePage:(id)sender {//! \private
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = (frame.size.width) * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
	//Set the enabled state of the next and previous arrows
	[self setScrollArrowStatus];
}

/**
 @brief change to the next image if there is a next image
 
 also update the status of the scroll arrows by calling setScrollArrowStatus
 
 */
- (IBAction)nextImage:(id)sender{
	if (pageControl.currentPage <= pageControl.numberOfPages -1) {
		++pageControl.currentPage;
	}
//	[self loadScrollViewWithPage:pageControl.currentPage];
	CGRect frame = scrollView.frame;
    frame.origin.x = (frame.size.width) * pageControl.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	//Set the enabled state of the next and previous arrows
	[self setScrollArrowStatus];
	
}

/**
 @brief change to the previous image if there is a previous image
 
 also update the status of the scroll arrows by calling setScrollArrowStatus
 
 */
- (IBAction)previousImage:(id)sender{
	if (pageControl >0 ) {
		--pageControl.currentPage;
	}
	

	CGRect frame = scrollView.frame;
    frame.origin.x = (frame.size.width) * pageControl.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	//Set the enabled state of the next and previous arrows
	[self setScrollArrowStatus];
	
	
}
/**
 @brief Enable/Disable the image scroll arrows as appropriate
 
 Checks the current page value.  If the page is the first page then the back
 arrow is disabled, if not it is enabled.  If the page is the last page then 
 the next arrow is disabled, otherwise it is enabled.
 
 This object also changes the image label shown just below the image.  This function
 is done here becase it is convenient.
 */
- (void)setScrollArrowStatus{//! \private
	if (self.pageControl.currentPage == 0) {
		previousButton.enabled = NO;
	}else{
		previousButton.enabled = YES;
	}
	if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
		nextButton.enabled = NO;
	}else {
		nextButton.enabled = YES;
	}
	
	NSString *desc = [[NSString alloc] initWithFormat:(self.pageControl.currentPage == 0 ? 
													   NSLocalizedString(@"Past Image", @"Past Image"):
													   NSLocalizedString(@"New Image %i", @"New Image %i")),self.pageControl.currentPage]; 
	self.imageDescription.text = desc;
	[desc release];
	
}


- (void)dealloc {//! \private
	[transient release];
    [super dealloc];
}

/**
 @brief Action connected to the Finder Chart button. 
 
 Instantiates a WebView and passes the finder chart web page URL.
 */


- (IBAction)displayFinderChart:(id)sender {//! \private
    WebViewController *finderImageView = [[WebViewController alloc]
												  initWithNibName:@"FinderImageWebView"
												  bundle:nil];
	finderImageView.title = @"Finder Chart";

	[finderImageView webViewForURL:self.transient.FinderURLString];
	finderImageView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:finderImageView animated:YES];
	[finderImageView release];
}

/**
 @brief Action connected to the Compose button
 
 Composes and email subject and body with details about the current event.  It also adds
 two image attachments to the email, the reference image and image 1. It then calls the 
 MFMailComposeMailViewConroller and displays the mail composer.  When the user either 
 sends the email or cancels the app returns to the detail view.
 */


- (IBAction)emailEvent:(id)sender {
	NSMutableString *theMessageString;
	theMessageString = [[NSMutableString alloc] init];
	
	NSString *tempString = [[NSString alloc] initWithFormat:@"%@ Event %@", 
							[self.transient valueForKey:@"EventType"],self.eventID.text];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init]; 
    picker.mailComposeDelegate = self; 
    [picker setSubject:tempString]; 
	[tempString release];
	[theMessageString appendString:@"Please note this interesting Transient Event.\n\n"];
	[theMessageString appendFormat:@"%@\n", [[self.transient valueForKey:@"EventType"] uppercaseString]];

	[theMessageString appendFormat:@"Event ID: %@\n%@\nEvent Time: %@\n%@\n%@\n",
	 self.eventID.text, self.coordinates.text, [self.transient valueForKey:@"EventDate"],self.alertTime.text, self.attribution.text];
	
	NSString *bodyString = [[NSString alloc] initWithString:theMessageString];
	[picker addAttachmentData:UIImageJPEGRepresentation([UIImage imageWithData:transient.ReferenceImage], 10) mimeType:@"/image/jpeg" fileName:@"ReferenceImage.jpg"];
	[picker addAttachmentData:UIImageJPEGRepresentation([UIImage imageWithData:transient.Image1], 10) mimeType:@"/image/jpeg" fileName:@"TransientImage1.jpg"];
	[picker setMessageBody:bodyString isHTML:NO]; 
	[theMessageString release];
	[bodyString release];
    // Present the mail composition interface. 
    [self presentModalViewController:picker animated:YES]; 
    [picker release]; // Can safely release the controller now. 
}

#pragma mark -
#pragma mark UIScrollViewDelegate


/**
 @brief updates the page controller if the user scrolls using a swipe
 gesture or the forward back arrows.
 
 
 */

- (void)scrollViewDidScroll:(UIScrollView *)sender {//! \private
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

/** 
 @brief At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {//! \private
	//add this replication of the stuff in DidScroll because for some reason
	//did scroll is not being called on the first scroll
	CGFloat pageWidth = sender.frame.size.width;
	int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	self.pageControl.currentPage = page;
	// load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	//    [self loadScrollViewWithPage:page - 1];
	
    pageControlUsed = NO;
	//Set the enabled state of the next and previous arrows
	[self setScrollArrowStatus];
}


#pragma mark -
#pragma mark MailComposer Delegate

// The mail compose view controller delegate method 
- (void)mailComposeController:(MFMailComposeViewController *)controller 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError *)error 
{ //! \private
    [self dismissModalViewControllerAnimated:YES]; 
} 





@end
