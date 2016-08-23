//
//  EventListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//


#import "ObjectInfoPageController.h"

#import "EventListController.h"
#import "EventDetailController.h"
#import "Transient_EventsAppDelegate.h"
#import "JSON.h"
#import "Constants.h"
#import "ImageLoadingOperation.h"
#import "AltAzComputation.h"
#import "FinderImageWebViewController.h"
#import <AudioToolbox/AudioServices.h>

#define kTabBarTag 4096
#define kNoSelection	-1

NSString *const ImageLoadingPlaceholder = @"Loading";

@implementation EventListController
@synthesize navController;
@synthesize transientDataArray;
//@synthesize photoURLs;
@synthesize	cachedImages;
@synthesize resultsData;
@synthesize urlConnection;
@synthesize loadingImage;
@synthesize	currentSelection;
@synthesize resumptionToken;
@synthesize alertImage;
@synthesize tableView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		//set the page title
		self.title = NSLocalizedString(@"Event List", @"Event List Page Title");
		//Set the icon for the tab bar for the Event List
		self.tabBarItem.image = [UIImage imageNamed:@"ELicon.png"];
		//Allocate the operation queue and set the number of concurent 
		//jobs to one.  There is a reason to keep it at one but I forget
		//why.  If you change it test carefully
		operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
		//Allocate and initialize some other objects
//		photoURLs = [[NSMutableArray alloc] init];
        cachedImages = [[NSMutableDictionary alloc] init];
		resultsData = [[NSMutableData alloc] init];
		
		//Get the Loading… image so we do not need to retrieve it many times later
		
		UIImage *image = [UIImage imageNamed:@"NoImage.png"];
		//resize the image to the proper size for the table cells
		CGSize newSize ;
		newSize.height = kTableViewRowHeight-5;
		newSize.width = kTableViewRowHeight-5;
		UIGraphicsBeginImageContext( newSize );
		[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		self.loadingImage = newImage;
		self.currentSelection = nil;
		self.resumptionToken = 0;
		loadingMoreData = NO;
		
		//Get a pointer to userDefaults so we can use it later
		userDefaults = [NSUserDefaults standardUserDefaults];
		

    }
    return self;
}
/**
 @brief sets the background image and instantiates the table view
 
 
 */

- (void)loadView {
	[super loadView];
	
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [imageView setImage:[UIImage imageNamed:@"BGtelescope.jpg"]];
    }
    else
    {
        [imageView setImage:[UIImage imageNamed:@"BGtelescope_Big.jpg"]];
    }
	[self.view addSubview:imageView];
	CGRect tableBounds;
	tableBounds = self.view.bounds;
	tableBounds.origin.y	 = 0;
	tableBounds.size.height = tableBounds.size.height - (48 + 44);
	[self.tableView = [UITableView alloc] initWithFrame:tableBounds style:UITableViewStylePlain];
	
	
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:self.tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//we turn off bouncing so we do not see the white background.  I tried lots of ways around
	//this but if we want to use images as the cell background the ends of the table will
	//always be white when we scroll past the end, so we do not let it.
	UIColor *navBarColor = kNavBarColor;
	self.navController.navigationBar.tintColor=navBarColor;
	self.tableView.bounces = YES;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.alertImage = [UIImage imageNamed:@"AlertIcon.png"];
	
	//Set up the notification center to tell it we are listing to the kReloadNotification and the 
	//kRefreshNotification.
	[[NSNotificationCenter defaultCenter]addObserver:self 
											selector:@selector(setNeedsReload)
												name:kReloadNotification
											  object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self 
											selector:@selector(setNeedsRefresh)
												name:kRefreshNotification
											  object:nil];	
	[[NSNotificationCenter defaultCenter]addObserver:self 
											selector:@selector(alertOccurred)
												name:kAlertOccurredNotification
											  object:nil];	
	self.navController.navigationBar.barStyle = UIBarStyleBlack;

	
//	self.view.backgroundColor = [UIColor darkGrayColor];	
	
	//Add the refresh button and the help button to the Nav Bar
	UIBarButtonItem  *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																					target:self action:@selector(reloadEvents)];

	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
	
    UIBarButtonItem *helpButton		= [[UIBarButtonItem alloc] initWithTitle:@"Help"
																	style:UIBarButtonItemStyleBordered
																   target:self 
																   action:@selector(displayHelp)];
	self.navigationItem.leftBarButtonItem  = helpButton;
	[helpButton	   release];
	
	//Set some flags - note that we set the reloadNeeded flag so that when viewWillAppear is called
	//the data is loaded
	returningFromDetailView = NO;
	reloadNeeded = YES;
	refreshNeeded = NO;


	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated{
	//The view is appearing, check to see if we need to reload the data
	if(reloadNeeded){
		//clear the data
		self.resumptionToken = 0;
		NSArray *array = [[NSArray alloc] init];
		self.transientDataArray = array;
//		[self.photoURLs removeAllObjects];
		[self.cachedImages removeAllObjects];
		NSMutableData *data = [[NSMutableData alloc] init];
		self.resultsData = data;
		[data release];
		[array release];
		//tell the table view to reload - this will give is a blank screen because
		//we just cleared the table
		[self.tableView reloadData];
		//load the data
		[self showLoadingIndicators];
		[self beginLoadingTransientDataAsync];
		//clear the reload flag
		reloadNeeded = NO;

	}else {
		//We don't need to reload the data - set this flag to no
		returningFromDetailView = NO;
	}
	//We need to refresh
	if (refreshNeeded) {
		if ([userDefaults boolForKey:kVisibleObjectsOnlyKey]){
			//The visible objects only key is on so remove invisible objects
			[self removeNonVisibleObjects];
		}
		//Set the footer, because it may have changed
//		[self setFooterForTableView];
		//Reload the data
		[self.tableView reloadData];
		refreshNeeded = NO;
	}

	[super viewWillAppear:animated];	
}

- (void) viewDidAppear:(BOOL)animated{
	if (currentSelection != nil) {
//		We just came back from another view.  If there is a selection
		//we want to move the table view to that row and mark it as selected.
		//This lets the user see which row they just selected.
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:currentSelection] 
													   withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView selectRowAtIndexPath:currentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	//Check to see if we are loading data as we depart the page.
	//if so we will cancel the load assuming that the user
	//does not want to see this data
	if (urlConnection != nil){
		[urlConnection cancel];
		//we canceled the load so the next time we re-enter this page we need to 
		//load data
		[self setNeedsReload];
		[self hideLoadingIndicators];
		self.urlConnection = nil;
	}
	[super viewWillDisappear:animated];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	NSLog(@"EventListController: Did receive memory warning");
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
	[self.cachedImages removeAllObjects];
}

- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[operationQueue release];
	[navController release];
//	[photoNames release];
//    [photoURLs release];
    [cachedImages release];
	[resultsData release];
	[currentSelection release];
	self.urlConnection = nil;
	[loadingImage release];

    [super dealloc];
}

#pragma mark -
#pragma mark Custom Methods

/**
 Can be called internally but typically this is called by another object by posting the
 kReloadNotification.  This method simply sets a flag which tells the EventListContoller
 that the data is stale because of some change, typically in settings.  The next time 
 this object becomes visible the data will be reloaded.  See viewWillAppear.
*/

- (void)setNeedsReload{
	reloadNeeded = YES;
}

/**
 Can be called internally but is typically called by anothe object sending the 
 kRefreshNotification.  This is called when it is only necessary to redisplay 
 the table due to a change in settings which may result in the color codings 
 of the table entries changing.  Note that we do check to see if the visible
 objects only switch is set.  If it is we play it safe and set the reloadNeeded
 flag.
*/

- (void)setNeedsRefresh{
	//Another object sends the kRefreshNeeded notification to trigger this.
	//This will cause the table to reload its data and redisplay without
	//reloading from the server.  Useful for just refreshing the table.
	self.resumptionToken = 0;
	if ([userDefaults boolForKey:kVisibleObjectsOnlyKey]) {
		//If the user has set the visible objects only key 
		//then we need to reload because we have tossed out some
		//data or never downloaded it in the first place
		reloadNeeded = YES;
	}else {
		//If we were displaying all events then we can just redo the display.
		refreshNeeded = YES;
	}

	
}

/**
 Handles a redisplay of the data if an alert occurs.  The data needs to be redownloaded 
 and redisplayed highlighting the alert. This is basically the same as what viewDidAppear
 does when reloadNeeded=YES except in this case we need to force it to happen even if
 the view is visible.  Higlighting of the alerts in the table is handled by 
 tableView:cellForRowAtIndexPath
*/
- (void)alertOccurred{
	//clear the data
	self.resumptionToken = 0;
	NSArray *array = [[NSArray alloc] init];
	self.transientDataArray = array;
	//		[self.photoURLs removeAllObjects];
	[self.cachedImages removeAllObjects];
	NSMutableData *data = [[NSMutableData alloc] init];
	self.resultsData = data;
	[data release];
	[array release];
	//tell the table view to reload - this will give is a blank screen because
	//we just cleared the table
	[self.tableView reloadData];
	//load the data
	[self showLoadingIndicators];
	[self beginLoadingTransientDataAsync];
	//clear the reload flag
	reloadNeeded = NO;
	
}

/**
 Called when the user presses the help button.
*/

- (IBAction)displayHelp{
	//instantiate the help view
	WebViewController *helpView = [[WebViewController alloc]
													 initWithNibName:@"FinderImageWebView"
													 bundle:nil];
	//Set the doNotScaleToFit flag so the page is displayed at full scale.  
	[helpView doNotScaleContentToFit];
	helpView.title = @"Help";
	//Get the help content and pass it to the help view
	[helpView webViewForURL:[[NSBundle mainBundle] pathForResource:kEventListHelpFile ofType:@"html"]];
	helpView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];
	
}

/**
 Called when the refresh button is pressed.  
*/

- (IBAction)reloadEvents{
	self.resumptionToken = 0;
	//clear out everythign and start the data download
	NSArray *array = [[NSArray alloc] init];
	self.transientDataArray = array;
	[array release];

//	[self.photoURLs removeAllObjects];
	[self.cachedImages removeAllObjects];
	[self.tableView reloadData];
	[self showLoadingIndicators];
	[self beginLoadingTransientDataAsync];
	
}

/**
	Creates the loading spinner and loading label programmatically and adds them to the 
	tableView.  We also change the reload button to a cancel button allowing the user to
	cancel the load operation.
 
	Call this method when the data load first starts.
 */

- (void)showLoadingIndicators
{
    if (!spinner) {
//		self.tableView.backgroundColor = [UIColor darkGrayColor];
		//first we make sure that no rows are selected
		self.currentSelection = nil;
		//now create the spinner and start it spinning
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner startAnimating];
        //Now create the label
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor redColor];
		loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.text = @"Waiting for server...";
        [loadingLabel sizeToFit];
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        //Figure out the rects for the spinner and the label
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.tableView.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = (self.tableView.bounds.size.height - spinnerFrame.size.height) / 4.0;
        spinner.frame = spinnerFrame;
		//add the spinner to the table view
        [self.tableView addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.tableView.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = (self.tableView.bounds.size.height - labelFrame.size.height) / 4.0;
        loadingLabel.frame = labelFrame;
		//add the label to the table view
        [self.tableView addSubview:loadingLabel];
		//Change the right button to a cancelButton
		UIBarButtonItem  *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																					   target:self action:@selector(cancelLoad)];
		self.navigationItem.rightBarButtonItem = cancelButton;
		[cancelButton release];

    }
}

/**
 This method turns off the loading indicators and removes the from the tableView.  It also changes
 the cancel button back to a refresh butto.
*/

- (void)hideLoadingIndicators
{
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        
        [loadingLabel removeFromSuperview];
        [loadingLabel release];
        loadingLabel = nil;
		UIBarButtonItem  *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																						target:self action:@selector(reloadEvents)];
		self.navigationItem.rightBarButtonItem = refreshButton;
		self.tableView.backgroundColor = [UIColor clearColor];

		[refreshButton release];

    }
}

/**
 This method cancels any in-process data retrieval and sets the result to nil.
*/

- (void)cancelLoad{
	[self.urlConnection cancel];
	[self hideLoadingIndicators];
	self.resultsData = nil;
}

/**
 This method scans through the transient data and removes all objects which
 are below the minimum altitude.  Someday we hope that we can tell the server to 
 only return visible objects but even if we do this we still want to run this
 filter so that do to rounding errors we do not display any RED coded objects when
 the Visible Objects Only switch is on.
*/

- (void)removeNonVisibleObjects{
	//First we set up a list of of objects that we want to keep.
	NSMutableArray *objectsToKeep = [[NSMutableArray alloc] init];
	//Initialize the AltAzComputaiton object
	AltAzComputation *altAzCalculator = [[AltAzComputation alloc] init];
	//now we step through the array of data
	for (NSDictionary *event in self.transientDataArray) {
		//compute the elevation
		altAzCalculator.RA=[[event objectForKey:kRightAscensionKey] doubleValue];
		altAzCalculator.DEC=[[event objectForKey:kDeclinationKey] doubleValue];
		
		double altitude = altAzCalculator.altitude;
		//Check to see if the object is visible
		if (altitude >= [userDefaults floatForKey:kMinAltitudeKey]) {
			//This object is visible, put in objectsToKeep array
			[objectsToKeep addObject:event];
		}		
	}
	//copy the visible objects into the data array
	self.transientDataArray = objectsToKeep;
	[altAzCalculator release];	
	[objectsToKeep release];
	
}

/**
 
 @brief Sets the footer for the table view.  DEPRECATED
 
The size of the footer depends on the
 number of rows in the table.  As long as the number of rows is greater than one
 page the footer is not needed but if the rows do not fill the page then we create
 a footer which just fills to the bottom of the page.  This prevents the white 
 background from showing through.  We needed to to this because in a plain table
 view it is not possible to display an background image or color for the table if
 you also want to use images as the background of the cells.
*/


- (void)setFooterForTableView{
	CGRect tableViewFooterFrame;
	//First we ask the tableView for its height.
	float tableViewHeight = self.tableView.frame.size.height;
	float rowsToFill;
	//get the number of rows in the table.
	NSInteger rowsInTable = [self.transientDataArray count];
	//set the static sizes for the table footer - these do not change
	tableViewFooterFrame.origin.x = 0;
	tableViewFooterFrame.origin.y = 0;
	tableViewFooterFrame.size.width = 320.0;
	 
	if (rowsInTable*kTableViewRowHeight > tableViewHeight) {
		//If the number of rows*rowHeight is greater than the height of the
		//tableView we do not need a footer so we set rowsToFill to zero
		rowsToFill = 0;
	}else{
		//The tableRows do not fill the page, figure out how many rows to fill.
		rowsToFill = tableViewHeight/kTableViewRowHeight - rowsInTable;
	}
	if (rowsToFill > 0){
//		//We need a footer so figure out how high
		tableViewFooterFrame.size.height = tableViewHeight - rowsInTable*kTableViewRowHeight;
	}else {
		//We do not need a footer so we make it have zero height
		tableViewFooterFrame.size.height = tableViewHeight - 5.0*kTableViewRowHeight;
	}
//	Create the footer
	UIView *footerView = [[UIView alloc] initWithFrame:tableViewFooterFrame];
	//Set the color
//	footerView.backgroundColor = [UIColor darkGrayColor];
	//Assign the footer to the table
	self.tableView.tableFooterView = footerView;
	[footerView release];
}




#pragma mark -
#pragma mark TableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

	return [self.transientDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *EventListingCellIdentifier = @"EventListingCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventListingCellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:EventListingCellIdentifier] autorelease];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.font = kTextLabelFont;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.font = kDetailTextLabelFont;
		cell.detailTextLabel.textColor = kDetailTextColor;
		// creating background view manually
		UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,280, kTableViewRowHeight)];
		
		// set it to the cell
		cell.backgroundView = backView;
		// release it
		[backView release];
	}
	if (indexPath.row % 2 == 1) 
		cell.backgroundView.backgroundColor = kTableOddRowColor;		
	else
		cell.backgroundView.backgroundColor = kTableEvenRowColor;
	
	//First we check to see if this cell is a resumption token if so we put More… in the cell
	if ([[[[self.transientDataArray objectAtIndex:indexPath.row] allKeys] objectAtIndex:0] isEqualToString:kResumptionTokenKey]) {
//		NSLog(@"A resumptionToken has been found");
//		NSLog(@"%@",[self.transientDataArray objectAtIndex:indexPath.row]);
		self.resumptionToken = [[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kResumptionTokenKey]intValue];
//		NSLog(@"resumptionToken= %i",self.resumptionToken);
		if (self.resumptionToken && !loadingMoreData) {
			cell.textLabel.text = NSLocalizedString(@"More…", @"More");
//			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.accessoryView = nil;
		}else if (loadingMoreData) {
			cell.textLabel.text=NSLocalizedString(@"Loading…", @"Loading");
			UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[aSpinner startAnimating];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView=aSpinner;
			cell.accessoryView.backgroundColor = cell.contentView.backgroundColor;
			[aSpinner release];
			
		}else{
			cell.textLabel.text = NSLocalizedString(@"End", @"End");
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = nil;

		}
		
		cell.textLabel.textColor = [UIColor blueColor];
		cell.imageView.image = nil;
		cell.detailTextLabel.text = nil;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		return cell;
	}
	
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	


	
	/*Now we will determine the color of the text
	Green for visible NOW
	Yellow for visible sometime
	Red for NEVER visible from this location.	
	*/
	//First lets define the colors:
	AltAzComputation *altAzCalculator = [[AltAzComputation alloc] initWithRA:[[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kRightAscensionKey] doubleValue]
																		 DEC:[[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kDeclinationKey] doubleValue]];
	UIColor *textLabelColor;
	double altitude = altAzCalculator.altitude;
	if (altitude >= [userDefaults floatForKey:kMinAltitudeKey]) {
		textLabelColor = kIsVisibleObjectColor;
	}else {
		if ([altAzCalculator maxAltitude] >= [userDefaults floatForKey:kMinAltitudeKey]) {
			textLabelColor = kWillBeVisibleObjectColor;
		}else{
			textLabelColor = kWontBeVisibleObjectColor;
		}
	}

	
	[altAzCalculator release];
	

	NSMutableString *label = [[NSMutableString alloc] initWithFormat:@"%@",[[self.transientDataArray objectAtIndex:indexPath.row] 
															  objectForKey:kTypeKey]];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        // is iPad
//        [label appendFormat:@": %@",[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kEventIDKey]];
//    }
	cell.textLabel.text = [label uppercaseString];
	[label release];
	//Now we will get the history dictionary and see if this eventID is in the dictionary.  If so
	//we set the Alpha compnent to 0.5 to gray out the entry indicating it has been viewed.
	NSMutableDictionary *history = [userDefaults objectForKey:kHistoryKey];
	if ([history objectForKey:[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kEventIDKey]]) {
		textLabelColor = [textLabelColor colorWithAlphaComponent:kVisitedAlpha];
	}else{
		textLabelColor = [textLabelColor colorWithAlphaComponent:kNotVisitedAlpha];
	}
	
	cell.textLabel.textColor = textLabelColor;
	//Set the detail text label
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  Mv=%.1f", 
								 [[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kAlertTimeKey],
								 [[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kMagnitudeKey]floatValue]];
	
	//Get the event type.  This will be use for the file name of the event type icon
	NSString *type = [[NSString alloc] initWithString:(NSString *)[[self.transientDataArray objectAtIndex:indexPath.row] 
																  objectForKey:kTypeKey]];

	NSString *imagePath = nil;
	//If there is an event type in the data AND if the Event Thumbnails switch is off get the path to the event type icon
	if (type && ![userDefaults boolForKey:kEventThumbnailsKey]) {

		imagePath = [[NSBundle mainBundle] pathForResource:type ofType:@"png"];
	}
	
	//If the imagePath is not nil then there was an icon for this event type.  If it was nil we will download the reference image as the icon
	NSURL *imageURL;
	if (imagePath) {
		imageURL = [[NSURL alloc] initFileURLWithPath:imagePath];
	}else {
		imageURL = [[NSURL alloc] initWithString:[[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:@"referenceImageURL"]objectAtIndex:0]];
	}
	
	

	cell.imageView.image = [self cachedImageForURL:imageURL];

	/**
	 Check here to see if this item is a current alert.  If it is
	 then set the animatedImages property.
	 This allows us to blink the image between the default icon and ALERT. We set animationDuration to the time of one
	 blink cyle and the animationCount to 0 for infinite blinking.
	 */
	if ([[userDefaults objectForKey:kAlertEventIDKey] isEqualToString:[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kEventIDKey]]) {
		//we will load the image and the Alerticon into an NSArray and set them as the animated images and then start animating
		NSArray *imageArray = [[NSArray alloc] initWithObjects:cell.imageView.image, alertImage, nil];
		cell.imageView.animationImages = imageArray;
		[imageArray release];
		cell.imageView.animationDuration = 1;
		cell.imageView.animationRepeatCount = 0;
		[cell.imageView startAnimating];
		
	}else {
		[cell.imageView stopAnimating];
		cell.imageView.animationImages = nil;
	}
	[type release];
	[imageURL release];
	//If there is a selected cell make sure it is highlighted
	if (currentSelection != nil && [currentSelection compare:indexPath] == NSOrderedSame) {
		[self.tableView selectRowAtIndexPath:currentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	
	return cell;
	
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return kTableViewRowHeight;
}

/**
 If a row is selected that means that the user wants to look at the detailed information 
 for this event.  Set up the EventDetailController and call the push it on the nave controller.
 We will also add this selection to the history dictionary.
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	//First we check to see if this cell is a More… cell if so we need to load more data
	if ([[[[self.tableView cellForRowAtIndexPath:indexPath] textLabel]text] isEqualToString:NSLocalizedString(@"More…", @"More")]) {
//		NSLog(@"Retrieve More data from server");
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		loadingMoreData = YES;
		[self.tableView reloadData];
		[self beginLoadingTransientDataAsync];
		self.currentSelection = nil;
		return;
	}
	if ([[[[self.tableView cellForRowAtIndexPath:indexPath] textLabel]text] isEqualToString:NSLocalizedString(@"End", @"End")]) {
		self.currentSelection = nil;
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	if ([[[[self.tableView cellForRowAtIndexPath:indexPath] textLabel]text] isEqualToString:NSLocalizedString(@"Loading…", @"Loading")]) {
		self.currentSelection = nil;
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	
	//Right now we only have one event type.  When we get more types of events we will need to 
	//check the stream and then set up the detail controller based on the type of stream.
	
    // Checking whether iPad/iPhone
    NSString *deviceType;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // is iPad
        deviceType = @"EventDetailView_iPad";
    }
    else {
        // is iPhone
        deviceType = @"EventDetailView_iPhone";
    }
    
	EventDetailController *eventDetailController = [[EventDetailController alloc] 
													initWithNibName:deviceType bundle:nil];
	eventDetailController.title = [[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kTypeKey];

	eventDetailController.hidesBottomBarWhenPushed = YES;
	returningFromDetailView = YES;
	reloadNeeded = NO;
	eventDetailController.eventDetails = [self.transientDataArray objectAtIndex:indexPath.row];
	//Add stuff here to pass the event pointer to the view controller
	self.currentSelection = indexPath;
    
    
/*	
    ObjectInfoPageController *objectInfoController =[[ObjectInfoPageController alloc]
                                                     initWithNibName:@"ObjectInfoView" bundle:nil];
    objectInfoController.title = [[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kTypeKey];
    objectInfoController.eventDetails = [self.transientDataArray objectAtIndex:indexPath.row];
    self.currentSelection =indexPath;
  */  
    
	//add this selection to the history
	NSDictionary *history = [userDefaults objectForKey:kHistoryKey];
	//First we check and see if this event has already been added to the history
	if (![history objectForKey:[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kEventIDKey]] ) {
		//It is a new event so now we must add it
		//Make a mutable dictionary and add the entries from the user defaults dictionary
		NSMutableDictionary *mutableHistory = [[NSMutableDictionary alloc] initWithCapacity:[history count] + 1];
		[mutableHistory addEntriesFromDictionary:history];
		//Now add the new event
		[mutableHistory setObject:[NSDate date] forKey:[[self.transientDataArray objectAtIndex:indexPath.row] objectForKey:kEventIDKey]];
		//And save the results to UserDefaults
		[userDefaults setObject:mutableHistory forKey:kHistoryKey];
		[mutableHistory release];
		
	}

	[self.navController pushViewController:eventDetailController animated:YES];
	[eventDetailController release];
}

#pragma mark -
#pragma mark JSON Data Loading

/**
 Used to download transient data as one continous string.  The conection runs in the background and the 
 NSURLConnection delegate methods are called with progress and completion information.  This is the method
 we use to retrieve the data.
 */


- (void)beginLoadingTransientDataAsync{
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"incoming" ofType:@"wav"];
//	SystemSoundID soundID;
//	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
//	AudioServicesPlaySystemSound (soundID);
	//First we set up the URLRequest note that we get the server address from UserDefaults
	//The kURLTimeoutInterval sets the timeout interval.  The minimum value allowed by the SDK
	//is a very inconvenient 240 seconds.  Maybe someday it can be shortened to say 30-60 seconds.
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:
																				[userDefaults objectForKey:kPrimaryEventServerKey]]
																   cachePolicy:NSURLRequestUseProtocolCachePolicy
																timeoutInterval:kURLTimeoutInterval];
//	NSLog(@"Server URL %@",[urlRequest URL]);
	//This is a POST request so we tell URLRequest
	[urlRequest setHTTPMethod:@"POST"];
	
	[urlRequest addValue:@"/jsonQuery/" forHTTPHeaderField:@"action"];
	//This is the POST Query
	NSMutableString *formattedString = [NSMutableString stringWithFormat:@"maxAge=%f&maxMagnitude=%f&streamNames=%@&resumptionToken=%i",
										[userDefaults floatForKey:kEventAgeKey],
										[userDefaults floatForKey:kLimitingMagnitudeKey],
										kStreams,
								 self.resumptionToken];
	
	//OK, now we need to append the desired event types
	//Lets get the event dictionary
	NSDictionary *eventDictionary = [[NSDictionary alloc] initWithDictionary:[userDefaults objectForKey:kEventTypesKey]];
	NSArray *keys = [eventDictionary allKeys];
	for (NSString *key in keys){
		if ([[eventDictionary objectForKey:key ] boolValue]){
			[formattedString appendFormat:@"&wantedClass=%@",key];
		}
	}
	[eventDictionary release];
	[formattedString replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [formattedString length])];
	//Add the POST query to the message body
	NSString *bodyString = [[NSString alloc] initWithFormat:@"%@",[formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//	NSLog(@"POST Body = %@",bodyString);
	char buffer[[bodyString length]];
	NSUInteger usedLength;
	//put the bytes in a c-string buffer
	[bodyString getBytes:&buffer 
			   maxLength: [bodyString length]
			  usedLength:&usedLength 
				encoding:NSUTF8StringEncoding 
				 options:NSStringEncodingConversionAllowLossy
				   range:NSMakeRange(0, [bodyString length])
		  remainingRange:NULL];
	//get the body text and make it data so we can add it to the URLRequest
	NSData *bodyData = [[NSData alloc] initWithBytes:buffer length:usedLength];
	[urlRequest setHTTPBody:bodyData];
	[bodyString release];
	[bodyData release];
	//Clear the results data
		self.resultsData = [[NSMutableData alloc] init];
	//Set URL Cache size.  Recommend 0 so that we force new data to be downloaded each time.
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	//Initiate the conection
	self.urlConnection = [NSURLConnection connectionWithRequest: urlRequest delegate: self];
	[urlRequest release];
	
}

/**
@deprecated used to add the sychronous load to the operation queue - deprecated 
 */


- (void)beginLoadingTransientData
{
    // One way to use operations is to create an invocation operation,
    // packaging up a target and selector to run.
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadTransientData) object:nil];
    [operationQueue addOperation:operation];
    [operation release];
}

/**
 this method was used to retrieve data during testing.  It is a synchronous blocking call to load the data
 it may be useful someday so it has been maintained.  If you use this directly then you cannot cancel the load or 
 update any loading indicators.
 It can also be called by using beginLoadingTransientData in which case it will run in the background but without
 callbacks.  Calling beginLoadingTransientDataAsync is more useful because you get callbacks with status updates.
*/


- (void)synchronousLoadTransientData
{
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"incoming" ofType:@"wav"];
//	SystemSoundID soundID;
//	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
//	AudioServicesPlaySystemSound (soundID);
	

	//	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.skyalert.org/jsonQuery/"]];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[userDefaults valueForKey:kPrimaryEventServerKey]]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest addValue:@"/jsonQuery/" forHTTPHeaderField:@"action"];
	NSString *formattedString = [NSString stringWithFormat:@"maxAge=%f&maxMagnitude=%f&streamNames=%@",
								 [userDefaults floatForKey:kEventAgeKey],
								 [userDefaults floatForKey:kLimitingMagnitudeKey],
								 kStreams];
	NSString *bodyString = [[NSString alloc] initWithString:[formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	char buffer[100];
	NSUInteger usedLength;
	[bodyString getBytes:&buffer 
			   maxLength:[bodyString length] 
			  usedLength:&usedLength 
				encoding:NSUTF8StringEncoding 
				 options:NSStringEncodingConversionAllowLossy
				   range:NSMakeRange(0, 100)
		  remainingRange:NULL];
	NSData *bodyData = [[NSData alloc] initWithBytes:buffer length:usedLength];
	[urlRequest setTimeoutInterval:kURLTimeoutInterval];
//	NSLog(@"Timeout Interval= %f",[urlRequest timeoutInterval]);
	[urlRequest setHTTPBody:bodyData];
	[bodyString release];
	[bodyData release];
	
	NSLog(@"%@\n%@",[urlRequest description], [urlRequest allHTTPHeaderFields]);
	
	NSURLResponse *response = nil;
	NSError *err = nil;
	NSData *resultsDataSync = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: &response error: &err];
	[urlRequest release];
	if(err){
		NSLog(@"Error sending POST request: %@", err);
		return;	
	}	
	
    
    // Get the contents of the URL as a string, and parse the JSON into Foundation objects.
    NSString *jsonString = [[NSString alloc]initWithData:resultsDataSync encoding: NSUTF8StringEncoding];
    NSArray *results = [jsonString JSONValue];
    [jsonString release];
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingTransientDataWithResults:) withObject:results waitUntilDone:NO];
}

/**
 Called when all of the data has been loaded.  Copies the results into the transient data array
 and calls the methods necessary to display teh data.
 */


- (void)didFinishLoadingTransientDataWithResults:(NSArray *)results
{
//	NSLog(@"Array of Events = \n%@",[results description]);
//	NSLog(@"Results array entry type = %@",[[results objectAtIndex:0]class]);
    [self hideLoadingIndicators];
	loadingMoreData = NO;
	//OK we got data.  If this was a resumption request we need to tack this onto the end
	//of the previous array.  If it is new (resumption token = 0) then we just set the
	//transient data array
	if (self.resumptionToken >0) {
		//first we get the current array
		NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.transientDataArray];
		//now we delete the last entry because it is the resumption token
		[array removeLastObject];
		//now we add the new objects to the array
		[array addObjectsFromArray:results];
		//Now check if the last object is a 0 resumption token
		if ([[[array lastObject] objectForKey:kResumptionTokenKey]intValue] == 0){
			//This is the end of the data so we will delete the last object and set the resumption token to =
			[array removeLastObject];
			self.resumptionToken = 0;
		}

		//now update the transient array

		self.transientDataArray = array;
		//clean up
		[array release];
	}else{
		NSMutableArray *array = [[NSMutableArray alloc] initWithArray:results];
		//Now check if the last object is a 0 resumption token
		if ([[[array lastObject] objectForKey:kResumptionTokenKey]intValue] == 0){
			//This is the end of the data so we will delete the last object and set the resumption token to =
			[array removeLastObject];
			self.resumptionToken = 0;
		}
		//Set the transient array
		self.transientDataArray = array;
		//clean up
		[array release];
	}

	
//	for (NSDictionary *object in self.transientDataArray){
//		//Get Image URL for the finder image
//		NSArray *array = [[NSArray alloc] initWithArray:[object objectForKey:@"referenceImageURL"]];
//
//		[photoURLs addObject:[NSURL URLWithString:[array objectAtIndex:0]]];
//		[array release];
//		
//	}
	
	//Now delete objects which are not visible if selected in preferences
	//The server may do this also but we want to make sure that rounding errors
	//do not result in some yellow or red coded objects when switch is ON
	if ([userDefaults boolForKey:kVisibleObjectsOnlyKey]){
		[self removeNonVisibleObjects];
	}
//	[self setFooterForTableView];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators]; // Hint to the user how many items are in the list.
}

#pragma mark -
#pragma mark Cached Image Loading
/**
 In order to speed up image loading we cache the images.  When an image is requested
 via url we check to see if there is an image in the cache.  If not we set the cache 
 to the Loading… image and then use ImageLoadingOperation to pull down the image
 from the web.  The next time we ask for the cached image it will load immediately.
 
 Note that this method only starts the image loading.  ImageLoadingOperation then
 calls back - (void)didFinishLoadingImageWithResult:(NSDictionary *)result to handle the
 new image.
*/

- (UIImage *)cachedImageForURL:(NSURL *)url
{
    id cachedObject = [cachedImages objectForKey:url];
    if (cachedObject == nil) {
        // Set the loading placeholder in our cache dictionary.
      [cachedImages setObject:loadingImage forKey:url];        
        cachedObject = [cachedImages objectForKey:url];
        // Create and enqueue a new image loading operation
        ImageLoadingOperation *operation = [[ImageLoadingOperation alloc] initWithImageURL:url target:self action:@selector(didFinishLoadingImageWithResult:)];
		operation.smallImages = YES;
        [operationQueue addOperation:operation];
        [operation release];
    } else if ([cachedObject isEqual:loadingImage]) {
        // We're already loading the image. Don't kick off another request.
        //cachedObject = nil;
    }
    
    return cachedObject;
}

/**
 This is the callback method for ImageLoadingOperation.  When 
 the image has been loaded it passes the image and its url back
 in the result dictionary.  We then add the image to cachedImages 
 and reload the table.
*/


- (void)didFinishLoadingImageWithResult:(NSDictionary *)result
{
    NSURL *url = [result objectForKey:@"url"];
    UIImage *image = [result objectForKey:@"image"];
    
    // Store the image in our cache.
    // One way to enhance this application further would be to purge images that haven't been used lately,
    // or to purge aggressively in response to a memory warning.
	
    [cachedImages setObject:image forKey:url];


    [self.tableView reloadData];
}

#pragma mark -NSURLConnetionDelegate

/**
 Called when the first response is received from the server.  The message Waiting For Data… is
 rarely seen because it happens so fast.
*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//	NSLog(@"EventListController: Expecting %i bytes of data",response.expectedContentLength); 
	loadingLabel.text = @"Waiting for data…";
	[self.view setNeedsDisplay];
}

/**
 called occassionally as data is received.  On slower connections or when 
 a lot of data is recieved the number of bytes received message will be displayed
 */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[resultsData appendData:data];
//	NSLog(@"EventListController: Received %i bytes of data",[resultsData length]);
	loadingLabel.text = [NSString stringWithFormat:@"%d Bytes Received",[resultsData length]];
	[self.view setNeedsDisplay];	
}

/**
 Called when all of the data has been successfully received.
 Then calls teh JSON parser which is a category added to NSString
 Posts various alerts if there is no data, no events or the data
 cannot be parsed.  Finally, calls didFinishLoadingTransientDataWithResults
 */


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSArray *results = nil;
	NSString *jsonString = [[NSString alloc]initWithData:resultsData encoding: NSUTF8StringEncoding];
//	NSLog(@"jsonString = \n%@",jsonString);
	if ([jsonString length] == 0){
		//No data was received.  This is typically a server error
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Data Received", @"No Data Received") 
														message:NSLocalizedString(@"No data was received from the server.  It is probably down. Try again later.", 
																				  @"No Data Received Message")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}else
	if ([jsonString length] == 2) {
		//If we get two characters it is typically [] - empty data.  Present an alert.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Events Received", @"No Events Received") 
														message:NSLocalizedString(@"Check your settings, there are no events which meet your criteria.  Change your settings to find more events and try again", 
																				  @"No Events Received Message")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];

		
	}else {
		//we received data so lets try to parse
		results = [jsonString JSONValue];
//		NSLog(@"EventListController: Received %i bytes of data, parsed %i objects",[jsonString length], [results count]);
		if([results count] == 0){
//			NSLog(@"EventListController: Unparsable data\n%@",jsonString);
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server Error", @"Server Error") 
															message:NSLocalizedString(@"Received data but it could not be parsed, probable server error. Try again later.", 
																					  @"Could Not Parse Data Message")
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
	}

	[self didFinishLoadingTransientDataWithResults:results];		

    [jsonString release];
	self.urlConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"NSURLConnection did fail with error: %@", error);
	[self hideLoadingIndicators];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transient Data loading Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];

}

//- (NSURLRequest *)connection:(NSURLConnection *)connection 
//			 willSendRequest:(NSURLRequest *)request 
//			redirectResponse:(NSURLResponse *)redirectResponse{
//	NSLog(@"EventListController: Redirect Requested\nWILL SEND REQUEST \n%@\n\nREDIRECT RESPONSE\n%@", [request description], [redirectResponse description]);
//	return request;
//}

@end
