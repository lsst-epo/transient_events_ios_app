//
//  EventDetailController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/10/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//



#import "EventDetailController.h"
#import "FinderImageViewController.h"
#import "Transient.h"
#import "Transient_EventsAppDelegate.h"
#import "Constants.h"
#import "ImageLoadingOperation.h"
#import	"FinderImageWebViewController.h"
#import "AltAzComputation.h"

#define kBookmarkButtonLabel NSLocalizedString(@"Add To Bookmarks", @"Add To Bookmarks Button Label")
#define kTransitionDuration .5
#define kImageSeparation	20

NSString *const LoadingPlaceholder = @"Loading";

@interface EventDetailController (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void)addTransientDataToCoreDataStore;

@end

@implementation EventDetailController

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
//@synthesize imageDictionary;
@synthesize scrollView;
@synthesize pageControl;
@synthesize eventDetails;
@synthesize photoURLs;
@synthesize	cachedImages;
@synthesize cachedImageStatus;
@synthesize	nextButton;
@synthesize	previousButton;
@synthesize imageDescription;
@synthesize	progressBar;
@synthesize plusButton;
@synthesize backgroundView;
@synthesize streamIconLeft;
@synthesize streamIconRight;

/**
 @brief Designated initializer.  Call with nib "EventDetailView.xib"
 
 Initializes most objects.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		photoURLs = [[NSMutableArray alloc] init];
		cachedImages = [[NSMutableDictionary alloc] init];
		cachedImageStatus = [[NSMutableDictionary alloc] init];
		operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
		userDefaults = [NSUserDefaults standardUserDefaults];
		bookmarkThreadRunning = NO;
		
		
    }
    return self;
}



/**
 @brief Sets up the email button in the toolbar and the calls fillInEventData
 and loadScrollViewWithPages.  
 
 Note that the eventDetails NSDictionary property must be set
 by the caller prior to pushing this object onto the navigation stack.  The 
 transient property must be set before this method is executed.
 
 
 */
- (void)viewDidLoad {
	

	UIBarButtonItem  *emailButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																				target:self action:@selector(emailEvent:)];

	self.navigationItem.rightBarButtonItem = emailButton;
	UIColor *toolbarColor = kNavBarColor;
	self.toolbar.tintColor = toolbarColor;
	[self fillInEventData];
	[emailButton release];
	scrollView.contentSize = CGSizeMake((scrollView.frame.size.width) * [self.photoURLs count],
										scrollView.frame.size.height);

	pageControl.numberOfPages = [self.photoURLs count];
    pageControl.currentPage = 1;
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.title = [self.eventDetails objectForKey:kTypeKey];
	[self changePage:self];
}

- (void)viewWillDisappear:(BOOL)animated{
	//We cannot leave until the thread is done
//	while (bookmarkThreadRunning) {
//		//do nothing
//		sleep(1);
//	}
	UIViewController *topController = [self.navigationController topViewController];
	if (![topController isKindOfClass:[WebViewController class]]) {
		[operationQueue cancelAllOperations];
	}
	
	self.title = NSLocalizedString(@"Event Details", @"Event Details button label");
	
	[super viewWillDisappear:animated];
}

- (void)dealloc {
	[photoURLs release];
	[cachedImages release];
	[cachedImageStatus release];
	[operationQueue release];
    [super dealloc];
}

/**
 @brief fill in all of the textual and numerical data on the screen.
 
 The method also computes the current and maximum elevation using the AltAzComputation
 object so that it can fill in the Alt and Az data
 
 
 */
- (void)fillInEventData{
	self.eventID.text = [self.eventDetails objectForKey:kEventIDKey];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RAFormat" ofType:@"plist"];
	NSMutableArray *RAFormatArray = [[NSMutableArray alloc] initWithContentsOfFile:path];

	
	if ([userDefaults integerForKey:kRAFormatKey] == 0  ) {
		double RA, DEC, sec;
		NSInteger deg, hours, min;
		RA = [[self.eventDetails objectForKey:kRightAscensionKey] doubleValue];
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
		DEC = [[self.eventDetails objectForKey:kDeclinationKey] doubleValue];
		deg = (int)DEC;
		DEC -= deg;
		DEC *=60;
		DEC = fabs(DEC);
		min = (int)DEC;
		DEC -= min;
		sec = DEC * 60.0;
		NSString *decStr = [[NSString alloc]  initWithFormat:@"%i˚ %02im %.2fs", 
						   deg, min, sec ];
		
		self.coordinates.text = [NSString stringWithFormat:@"RA= %@  DEC= %@", RAStr, decStr];
		[RAStr release];
		[decStr release];
		
	}else {
		self.coordinates.text = [NSString stringWithFormat:@"RA= %5.6f˚  Dec= %5.6f˚", 
								 [[self.eventDetails objectForKey:kRightAscensionKey] doubleValue],
								 [[self.eventDetails objectForKey:kDeclinationKey]doubleValue] ];
	}

	[RAFormatArray release];	
	self.magnitude.text = [NSString stringWithFormat:@"Mv= %.2f",[[self.eventDetails objectForKey:kMagnitudeKey]floatValue]];
//	self.eventTime.text = [NSString stringWithFormat:@"Event %@",[self.eventDetails objectForKey:kEventTimeKey]];
	self.alertTime.text = [NSString stringWithFormat:@"Alert Time: %@",[self.eventDetails objectForKey:kAlertTimeKey]];
		
	AltAzComputation *altAzCalculator = [[AltAzComputation alloc] initWithRA:[[self.eventDetails objectForKey:kRightAscensionKey] doubleValue]
																		 DEC:[[self.eventDetails objectForKey:kDeclinationKey]doubleValue]];
	self.azAltCoordinates.text = [NSString stringWithFormat:@"Az= %5.5f˚ Alt= %5.5f",altAzCalculator.azimuth, altAzCalculator.altitude];;
	self.airmass.text = 
		(altAzCalculator.altitude <=0.0 ? @"":
		 [NSString stringWithFormat:@"Airmass= %5.2f",
		 (sin(M_PI*altAzCalculator.altitude) == 0 ?9999.9:1/sin(M_PI*altAzCalculator.altitude/180.0))]);
//	double maxAltitude = [altAzCalculator maxAltitude];
	[altAzCalculator release];
	
	self.attribution.text = @"Drake et al. 2009, ApJ, 696, 870";
	NSMutableArray *array = [[NSMutableArray alloc] init];
	[array addObjectsFromArray:[self.eventDetails objectForKey:kReferenceImageURLKey]];
	[array addObjectsFromArray:[self.eventDetails objectForKey:kFreshImageURLKey]];
//	[array addObjectsFromArray:[self.eventDetails objectForKey:@"finding_chart"]];
	for (NSString *aString in array){
		[self.photoURLs addObject:[NSURL URLWithString:aString]];
	}
	[array release];
	NSString *imageName = [[NSString alloc] initWithFormat:@"%@Big.jpg", [self.eventDetails objectForKey:kTypeKey]];
	UIImage *image = [UIImage imageNamed:imageName];
	if (image != nil) {
		self.backgroundView.image = image;
	}	
	[imageName release];
	if ([[eventDetails objectForKey:kStreamKey] isEqualToString:@"CRTS"]) {
		//This is a CRTS stream, display their icons
//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	if ([[eventDetails objectForKey:kStreamKey] isEqualToString:@"CRTS2"]) {
		//This is a CRTS2 stream, display their icons
		//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	if ([[eventDetails objectForKey:kStreamKey] isEqualToString:@"CRTS3"]) {
		//This is a CRTS3 stream, display their icons
		//		streamIconLeft.image = [UIImage imageNamed:@"CSS(60px).jpg"];
		streamIconLeft.image = [UIImage imageNamed:@"skyalert.png"];
		streamIconLeft.alpha = 1.0;
		streamIconRight.image = [UIImage imageNamed:@"CRTS(60px).jpg"];
	}
	
	
}

#pragma mark -
#pragma mark Custom Methods

- (void)loadScrollViewWithPage:(int)page {

    if (page < 0) return;
    if (page >= [self.photoURLs count]) return;
	
    // replace the placeholder if necessary
    UIImageView *imageView = [[UIImageView alloc] initWithImage:
							  [self cachedImageForURL:[photoURLs objectAtIndex:page]]];

    // add the controller's view to the scroll view if it does not already exist
	
    if (nil == imageView.superview && [[cachedImageStatus objectForKey:[photoURLs objectAtIndex:page]] isEqualToString:@"Changed"]) {
        CGRect frame = scrollView.frame;
        frame.origin.x = (frame.size.width) * page + kImageSeparation/2;
        frame.origin.y = 0;
		frame.size.width = frame.size.width - kImageSeparation;
        imageView.frame = frame;
        [scrollView addSubview:imageView];
		[cachedImageStatus removeObjectForKey:[photoURLs objectAtIndex:page]];
    }
	[imageView release];

}

/**
 Called when the user touches the page controller.  Gets the requested page from the pageControl object
 and then scrolls to that page by getting the page's frame.  Also tells this object to load the 
 pages on either side of the current page to help get the pages loaded in advance of the request to show
 the image.  At the end, it sets the scroll arrow status so that if there are no more pages in a particular
 direction the arrows are disabled.
 */
- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page + 1];
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
 Action connected to the right image scroll arrow.  Checks to see if there are more images
 in the requested direction, if so, scroll to the next image and set the scroll arrow status.
 
 The setScrollArrow status method should ensure that this function does not get called if there
 are no more images but just in case we do check to make sure, otherwise it could crash app.
 */

- (IBAction)nextImage:(id)sender{
	if (pageControl.currentPage <= pageControl.numberOfPages -1) {
		++pageControl.currentPage;
	}
	[self loadScrollViewWithPage:pageControl.currentPage];
	CGRect frame = scrollView.frame;
    frame.origin.x = (frame.size.width) * pageControl.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	//Set the enabled state of the next and previous arrows
	[self setScrollArrowStatus];
	
}

/**
 Action connected to the left image scroll arrow.  Checks to see if there are more images
 in the requested direction, if so, scroll to the next image and set the scroll arrow status.
 
 The setScrollArrow status method should ensure that this function does not get called if there
 are no more images but just in case we do check to make sure, otherwise it could crash app.
 */

- (IBAction)previousImage:(id)sender{
	if (pageControl >0 ) {
		--pageControl.currentPage;
	}
	
	[self loadScrollViewWithPage:pageControl.currentPage];
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

- (void)setScrollArrowStatus{
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

/**
 @brief Sets the value of the progress bar and also causes it to be shown/hidden
 
 The fill of the progress bar is set by calling this function with an NSNumber 
 set to a value between 0 and 1.  When this function is called with a value >
 the progress bar and status bar network activity indicators are displayed, 
 the back button is hidden, the bookmark button is disabled and the progress 
 bar fill is set.
 
 When you want the progress bar to hide, pass a progress value < 0.  This will
 also reactivate the back button.
 
 NOTE:  If the user returns to the Event list or another tab page the status
 indicator disappears but the status bar network activity indicator will
 continue to spin until the download is complete.  This shows the user that
 something is happening.
 
 ALSO NOTE: If the user starts a bookmark download and then returns to the event
 list and then comes back to a detail view of this event the status bar WILL NOT
 reappear even if the download is still in progress.  The reason for this is that 
 the NEW EventDetailDisplay object is not the same as the old one which owns the 
 status bar.  The old event just exists as a faceless object until the download
 completes.
 */

- (void)incrementProgressBar:(NSNumber *)progress{
//		NSLog(@"Progress: %f", [progress floatValue]);
	if ([progress floatValue] >=0 ) {
		progressBar.hidden = NO;
		self.plusButton.enabled = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//		self.navigationItem.hidesBackButton = YES;

		progressBar.progress = [progress floatValue];
	}else {
		progressBar.hidden = YES;
		self.plusButton.enabled = YES;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		self.navigationItem.hidesBackButton = NO;
	}
	[progressBar setNeedsDisplay];
}

/**
 @brief Action connected to the Add Bookmark button (+).  
 
 The method displays an action sheet giving the user the option to either add
 the event to their bookmarks or cancel.  
 
 The action sheet calls back the action sheet delegate method 
 
 - (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

 */

- (IBAction)addBookmark:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add this event to your bookmark list?" ,@"Add New Bookmark Title")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 		
										 destructiveButtonTitle:nil
											  otherButtonTitles:nil];
	[actionSheet addButtonWithTitle:kBookmarkButtonLabel];
	[actionSheet showFromToolbar:self.toolbar];
	[actionSheet release];
	
}

/**
 @brief Action connected to the Finder Chart button. 
 
 Instantiates a WebView and passes the finder chart web page URL.
 */
- (IBAction)displayFinderChart:(id)sender {
    WebViewController *finderImageView = [[WebViewController alloc]
												  initWithNibName:@"FinderImageWebView"
												  bundle:nil];
	finderImageView.title = @"Finder Chart";

	[finderImageView webViewForURL:[[self.eventDetails objectForKey:kFinderChartPageURLKey]objectAtIndex:0]];
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
							[self.eventDetails valueForKey:kTypeKey],self.eventID.text];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init]; 
    picker.mailComposeDelegate = self; 
    [picker setSubject:tempString]; 
	[tempString release];
	[theMessageString appendString:@"Please note this interesting Transient Event.\n\n"];
	[theMessageString appendFormat:@"%@\n", [[self.eventDetails objectForKey:kTypeKey] uppercaseString]];
	[theMessageString appendFormat:@"Event ID: %@\n%@\nEvent Time: %@\n%@\n%@\n",
	 self.eventID.text, self.coordinates.text, [self.eventDetails objectForKey:kEventTimeKey],self.alertTime.text, self.attribution.text];
	
	NSString *bodyString = [[NSString alloc] initWithString:theMessageString];
	[picker addAttachmentData:UIImageJPEGRepresentation([self cachedImageForURL:[photoURLs objectAtIndex:0]], 10) mimeType:@"/image/jpeg" fileName:@"ReferenceImage.jpg"];
	[picker addAttachmentData:UIImageJPEGRepresentation([self cachedImageForURL:[photoURLs objectAtIndex:1]], 10) mimeType:@"/image/jpeg" fileName:@"TransientImage1.jpg"];
    [picker setMessageBody:bodyString isHTML:NO]; 
	[theMessageString release];
	[bodyString release];
    // Present the mail composition interface. 
    [self presentModalViewController:picker animated:YES]; 
    [picker release]; // Can safely release the controller now. 
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
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
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
//    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	

    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
//add this replication of the stuff in DidScroll because for some reason
	//did scroll is not being called on the first scroll
		CGFloat pageWidth = sender.frame.size.width;
		int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
		// load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
		//    [self loadScrollViewWithPage:page - 1];
		[self loadScrollViewWithPage:page];
		[self loadScrollViewWithPage:page + 1];

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
{ 
    [self dismissModalViewControllerAnimated:YES]; 
} 


#pragma mark -
#pragma mark Action Sheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
//	while (bookmarkThreadRunning) {
//		//do nothing
//		sleep(1);
//	}

// If cancel is pressed we do nothing.  
	
	//Add Bookmark was pressed.  First we need to wait if there is already a bookmark thread
	//running.  If so, we need to wait. (This should not happen because the + button is disabled
	//while the thread is running.)  Once there is no bookmark thread running we 
	//create a new thread to add the data to the store by performing the 
	//addTransientDataToCoreDataStore method in the background.
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kBookmarkButtonLabel]){
		while (bookmarkThreadRunning) {
			//do nothing
			sleep(1);
		}
		
//		NSLog(@"Add to Bookmarks Button Pressed");
		[self performSelectorInBackground:@selector(addTransientDataToCoreDataStore) withObject:nil];
	}
}
/**
 This method is called as a background process to add the current transient event to the core data store.
 
 The method starts by creating a new  management object into which it copies the text data from the current event.  
 Since one of the goals of the bookmarks is to allow access when the device is offline it is not sufficint to simply
 copy the image URL's which were in the JSON string.  The actual images need to be downloaded and saved to the 
 managed object.  Each of the images is therefore downloaded in sequence and then placed in the managed object.
 On a slower internet connection this can take some time, hence this metho is run as a background thread.  After
 each image download is complete it calls back to the main thread to increment the progress indicator.
 
 Because the parent object must remain alive during the execution of this thread we do a [self retain] at the start
 followed by a [self release] at the end of the method.  This ensures that the object will not be deallocated prior
 to the completion of the download of the data.
 
 NOTE:  If the user quits the app during the download process whatever data has been retrieved will be saved, the remainder
 will be left empty.  Since the textual data is added instantly the bookmarks page will display the event properly 
 although possibly without the thumbnail image.  Some or all of the images may be missing.
 */
- (void)addTransientDataToCoreDataStore{
	//First set up a local autorelease memory pool for this method so that when it is called as a thread
	//memory is handled properly.
	NSAutoreleasePool * myPool = [[NSAutoreleasePool alloc] init];
	//now, retain self  so that this object stays in existance until the bookmarking process is complete
	[self retain];
	//Call back to the main thread and display the progress bar
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.0]
						waitUntilDone:NO];
	//set a flag so we know that this thread is in process
	bookmarkThreadRunning = YES;
	//Get the app's maanaged object context
	Transient_EventsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	[managedObjectContext retain];
	//Lock the context so that we don't screw things up.
	[managedObjectContext lock];
	//Add a new object
	Transient *transientBookmark = (Transient *) [NSEntityDescription
												  insertNewObjectForEntityForName:@"Transient"
												  inManagedObjectContext:managedObjectContext];
	//Fill in the text values
	transientBookmark.EventID = [self.eventDetails objectForKey:kEventIDKey];

	transientBookmark.EventStream = [self.eventDetails objectForKey:kStreamKey];
	transientBookmark.EventDate = [self.eventDetails objectForKey:kEventTimeKey];
	transientBookmark.AlertDate = [self.eventDetails objectForKey:kAlertTimeKey];
	transientBookmark.RightAscension = [NSNumber numberWithDouble:[[self.eventDetails objectForKey:kRightAscensionKey]doubleValue]];
	transientBookmark.Declination = [NSNumber numberWithDouble:[[self.eventDetails objectForKey:kDeclinationKey] doubleValue]];
	transientBookmark.VisibleMagnitude = [NSNumber numberWithFloat:[[self.eventDetails objectForKey:kMagnitudeKey] floatValue]];
	transientBookmark.Attribution = [NSString stringWithString:@"Drake et al. 2009, ApJ, 696, 870"];
	NSString *webURLstring = [[NSString alloc] initWithString:[[[self.eventDetails objectForKey:kFinderChartPageURLKey]objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	transientBookmark.FinderURLString= webURLstring;
	[webURLstring release];
	transientBookmark.EventType = [self.eventDetails objectForKey:kTypeKey];
	
	//We got the text, increment the status bar
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.1] 
						waitUntilDone:NO];
	
	//Get the path for the Missing Image… placholder image
	NSString *missingImagePath = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForResource:@"MissingImage" ofType:@"png"]];
	
	
	//For each image attempt to get the image, if successful put it into the object, if not put in the Missing Image… placeholder
	NSData *data = [[NSData alloc] initWithContentsOfURL:[photoURLs objectAtIndex:0]];
    UIImage *image = ((data && [data length]>0) ? [[UIImage alloc] initWithData:data] : [[UIImage alloc ]initWithContentsOfFile:missingImagePath]);
	transientBookmark.ReferenceImage = UIImageJPEGRepresentation(image,10);
	//we are going to stick this image in the CellImage just in case we need it
	transientBookmark.CellImage = UIImageJPEGRepresentation(image,10);
	[data release];
	[image release];
	
	//Now we need to get the cell image
	if (![userDefaults boolForKey:kEventThumbnailsKey]|| YES) {
		//We do not want the event thumbnail so we need to see if there is an icon for this event type
		NSString *type = [[NSString alloc] initWithString:(NSString *)[self.eventDetails  
																	   objectForKey:kTypeKey]];
		
		NSString *imagePath = nil;
		//If there is an event type in the data AND if the Event Thumbnails switch is off get the path to the event type icon
		if (type) {
			
			imagePath = [[NSBundle mainBundle] pathForResource:type ofType:@"png"];
		}
		
		//If the imagePath is not nil then there was an icon for this event type.  If it was nil we will download the reference image as the icon
		if (imagePath) {
			transientBookmark.CellImage =  UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:imagePath], 10);
		}else {
			//we do nothing because we already have the image
		}
		
	}
	
	//We got the image so increment the progress indicator
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.3] 
						waitUntilDone:NO];
	
	//Repeat the above process for the remaining 4 images.
	data = [[NSData alloc] initWithContentsOfURL:[photoURLs objectAtIndex:1]];
    image = ((data && [data length]>0) ? [[UIImage alloc] initWithData:data] : [[UIImage alloc ]initWithContentsOfFile:missingImagePath]);
	transientBookmark.Image1 = UIImageJPEGRepresentation(image,10);
	[data release];
	[image release];
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.5] 
						waitUntilDone:NO];
	data = [[NSData alloc] initWithContentsOfURL:[photoURLs objectAtIndex:2]];
    image = ((data && [data length]>0) ? [[UIImage alloc] initWithData:data] : [[UIImage alloc ]initWithContentsOfFile:missingImagePath]);
	transientBookmark.Image2 = UIImageJPEGRepresentation(image,10);
	[data release];
	[image release];
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.7] 
						waitUntilDone:NO];
	data = [[NSData alloc] initWithContentsOfURL:[photoURLs objectAtIndex:3]];
    image = ((data && [data length]>0) ? [[UIImage alloc] initWithData:data] : [[UIImage alloc ]initWithContentsOfFile:missingImagePath]);
	transientBookmark.Image3 = UIImageJPEGRepresentation(image,10);
	[data release];
	[image release];
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:0.9] 
						waitUntilDone:NO];
	data = [[NSData alloc] initWithContentsOfURL:[photoURLs objectAtIndex:4]];
    image = ((data && [data length]>0) ? [[UIImage alloc] initWithData:data] : [[UIImage alloc ]initWithContentsOfFile:missingImagePath]);
	transientBookmark.Image4 = UIImageJPEGRepresentation(image,10);
	[data release];
	[image release];
	
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:1.0] 
						waitUntilDone:NO];
	NSArray *array = [[NSArray alloc] initWithArray:[self.eventDetails objectForKey:kFindingChartImageKey]];
//	NSLog(@"%i",[array count]);
//	NSLog(@"%@",[[array objectAtIndex:0] description]);
	if ([[array objectAtIndex:0] isKindOfClass:[NSString class]]) {
		NSString *finderImageURLString = [[NSString alloc] initWithString:[[array objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:finderImageURLString]];
		image = [[UIImage alloc] initWithData:data];
		transientBookmark.FinderImage = UIImageJPEGRepresentation(image,10);
		[finderImageURLString release];
		[data release];
		[image release];
	}
	//clean up some memory
	[array release];
	[missingImagePath release];

	
	
	//save the new object to the core data store
	NSError *error = nil;
	if(![managedObjectContext save:&error]){
		NSLog(@"Could not save Transient Bookmark: %@", [error localizedDescription]);
	}
	//Turn off the progress indicators
	[self performSelectorOnMainThread:@selector(incrementProgressBar:) 
						   withObject:[NSNumber numberWithFloat:-1.0] 
						waitUntilDone:NO];
	//dispose of the autorelease pool and clean things up.
	[myPool release];
//	NSLog(@"Ending Bookmark Thread");
	[managedObjectContext unlock];
	[managedObjectContext release];
	bookmarkThreadRunning = NO;
	//We are done so release self so that it can be deallocated if necessary
	[self release];
	
}

#pragma mark -
#pragma mark Image Loading

/**
 Returns an image for a specific URL.  Once the image is downloaded it is stored in an NSDictionary where
 the key is the URL.  The next time that image is requested it will be retrieved from the cache rather than the
 web.  This helps the table redraw very quickly while only hitting the web once for each image.
 
 The actual image downloading is done on a background thread.  While downloading the image displayed is a 
 Loading… placeholder.
 */
- (UIImage *)cachedImageForURL:(NSURL *)url
{
    id cachedObject = [cachedImages objectForKey:url];
    if (cachedObject == nil) {
//		NSLog(@"EventDetailController: ImageURL = %@", [url description]);
        // Set the loading placeholder in our cache dictionary.
        [cachedImages setObject:[UIImage imageNamed:@"NoImage.png"] forKey:url];  
		[cachedImageStatus setObject:@"Changed" forKey:url];
        // Create and enqueue a new image loading operation
        ImageLoadingOperation *operation = [[ImageLoadingOperation alloc] initWithImageURL:url target:self action:@selector(didFinishLoadingImageWithResult:)];
        [operationQueue addOperation:operation];
        [operation release];
		[self changePage:self];
    } else if (![cachedObject isKindOfClass:[UIImage class]]) {
        // We're already loading the image. Don't kick off another request.
        //cachedObject = nil;
    }
    
    return cachedObject;
}

/**
 Called by ImageLoadingOperation when an image load from a URL is complete.  The new image
 is put in the image cache dictionary.
 */

- (void)didFinishLoadingImageWithResult:(NSDictionary *)result
{

	if ([result count]){
		NSURL *url = [result objectForKey:@"url"];
		UIImage *image = [result objectForKey:@"image"];
		
		// Store the image in our cache.
		// One way to enhance this application further would be to purge images that haven't been used lately,
		// or to purge aggressively in response to a memory warning.
		[cachedImages setObject:image forKey:url];
		[cachedImageStatus setObject:@"Changed" forKey:url];
		

	}
	//forces the new image to be displayed
	[self changePage:pageControl];
	

}


@end
