//
//  BookmarkListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "BookmarkListController.h"
#import "Transient.h"
#import "AltAzComputation.h"
#import "Constants.h"
#import "BookmarkDetailController.h"
#import "FinderImageWebViewController.h"


@implementation BookmarkListController
@synthesize navController;
@synthesize	managedObjectContext;
@synthesize fetchedResultsController;
@synthesize tableView;

/**
 Sets the title of the page and sets its own tab bar icon.  Also gets the NSUserDefaults object and the
 NSManagedObjectContext object for use locally.
 */
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Bookmarks", @"Bookmarks Page Title");
		self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0]autorelease];
		userDefaults = [NSUserDefaults standardUserDefaults];
		managedObjectContext = [[[UIApplication sharedApplication] delegate] managedObjectContext];
		[managedObjectContext retain];

	}
    return self;
}

/**
 @brief sets the background image and instantiates the table view
 
 
 */

- (void)loadView {
	[super loadView];
	
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
	[imageView setImage:[UIImage imageNamed:@"BGtelescope.jpg"]];
	[self.view addSubview:imageView];
	CGRect tableBounds;
	tableBounds = self.view.bounds;
	tableBounds.origin.y	 = 0;
	tableBounds.size.height = tableBounds.size.height - (48 + 44);
	[self.tableView = [UITableView alloc] initWithFrame:tableBounds style:UITableViewStylePlain];
	
	
//	[self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:self.tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIColor *navBarColor = kNavBarColor;
	self.navController.navigationBar.tintColor=navBarColor;

	//First set up the table view parameters.
	self.tableView.bounces = YES;
//	self.tableView.tableFooterView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DarkBackground.png"]]autorelease];
//	self.navController.navigationBar.barStyle = UIBarStyleBlack;
//	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;	
	
	//Now set up the navigation bar.  We need an edit button and a help button.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *helpButton		= [[UIBarButtonItem alloc] initWithTitle:@"Help"
																	style:UIBarButtonItemStyleBordered
																   target:self 
																   action:@selector(displayHelp)];
	self.navigationItem.leftBarButtonItem  = helpButton;
	[helpButton	   release];
	
	//CORE DATA
	//set the fetch request for CoreData.  We want to sort descending by AlertDate.  This puts the newest
	//items at the top.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transient"
											  inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"AlertDate" ascending:NO
										selector:@selector(localizedCaseInsensitiveCompare:)
										];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	[request setSortDescriptors:sortDescriptors];
	[request setIncludesPendingChanges:YES];
	[sortDescriptor release];
	[sortDescriptors release];
	//Instatiate our NSFetchedResultsController - there are no sections so the sectionNameKeyPath is nil
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
															 initWithFetchRequest:request
															 managedObjectContext:managedObjectContext
															 sectionNameKeyPath:nil
															 cacheName:@"BookmarksCache"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	//perform the fetch
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"BookmarkListcontroller Fetch Error: %@",[error localizedDescription]);
	}
	
	
    [super viewDidLoad];
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated{

	[self.tableView setEditing:editing animated:animated];
	[super setEditing:editing animated:animated];
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
	//when the view appears we want to set the fotter and reload the data
//	[self setFooterForTableView];
	[self.tableView	reloadData];
	[super viewWillAppear:animated];
}


- (void)displayHelp{
	//Instatiate the web view.  The FinderImageWebViewController is just what we want
	WebViewController *helpView = [[WebViewController alloc]
											  initWithNibName:@"FinderImageWebView"
											  bundle:nil];
	//Tell the view not to scale the content
	[helpView doNotScaleContentToFit];
	helpView.title = @"Help";
	//find the help page in the app bundle
	[helpView webViewForURL:[[NSBundle mainBundle] pathForResource:kBookmarkListHelpFile ofType:@"html"]];
	//hide the Tab Bar
	helpView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];
	
}

/**
 
 @brief DEPRECATED
 
 Sets the footer for the table view.  The size of the footer depends on the
 number of rows in the table.  As long as the number of rows is greater than one
 page the footer is not needed but if the rows do not fill the page then we create
 a footer which just fills to the bottom of the page.  This prevents the white 
 background from showing through.  We needed to to this because in a plain table
 view it is not possible to display an background image or color for the table if
 you also want to use images as the background of the cells.
 */

- (void)setFooterForTableView{
	CGRect tableViewFooterFrame;
	//	NSLog(@"TableView height = %f",self.tableView.frame.size.height);
	float tableViewHeight = self.tableView.frame.size.height;
	float rowsToFill;
	NSInteger rowsInTable = [[fetchedResultsController fetchedObjects]count];
	tableViewFooterFrame.origin.x = 0;
	tableViewFooterFrame.origin.y = 0;
	tableViewFooterFrame.size.width = 320.0;
	if (rowsInTable*kTableViewRowHeight > tableViewHeight) {
		rowsToFill = 0;
	}else{
		rowsToFill = tableViewHeight/kTableViewRowHeight - rowsInTable;
	}
	if (rowsToFill > 0){
		//		NSLog(@"Creating a footer view to fill %i rows",rowsToFill);
		tableViewFooterFrame.size.height = tableViewHeight - rowsInTable*kTableViewRowHeight;
	}else {
		tableViewFooterFrame.size.height = 0.0;
	}
	//	NSLog(@"Height of footer view is %f",tableViewFooterFrame.size.height);
	UIView *footerView = [[UIView alloc] initWithFrame:tableViewFooterFrame];
	footerView.backgroundColor = [UIColor darkGrayColor];
	self.tableView.tableFooterView = footerView;
	[footerView release];
}



- (void)dealloc {
	[navController release];
	[managedObjectContext release];
	[fetchedResultsController release];
	[tableView release];

    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//we could just return 1 since there is only 2 section but this allows
	//for sections later if we want to implement them
	NSUInteger count = [[fetchedResultsController sections] count];
    if (count == 0) {
        count = 1;
    }
    return count;
	
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	//since there is only one section we could just count the objects in the fetched results controller
	//but by asking for the count of the section this code will support multiple sections if 
	//that is desired in the future.
	if ([[fetchedResultsController sections] count] == 0) {
		return 0;
	}
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    //Attempt to retrieve a reusable cell identified with Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		//There was no reusable cell so we will create one and set it's parameters.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.font = kTextLabelFont;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.font = kDetailTextLabelFont;
		cell.detailTextLabel.textColor = kDetailTextColor;
		//here is where we set the background image for the cell
		// creating background view manullay
		UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320, 44)];	
		// set it to the cell
		cell.backgroundView = backView;	
		// release it
		[backView release];
    }
	if (indexPath.row % 2 == 1) {
		cell.backgroundView.backgroundColor = kTableOddRowColor;
	}		
	else
		cell.backgroundView.backgroundColor = kTableEvenRowColor;
	
	//Get the current object from the fetched results controller
	Transient *transient = [fetchedResultsController objectAtIndexPath:indexPath];
	[transient retain];
	//compute the color of the listing based on location and min elevation set in Settings
	AltAzComputation *altAzCalculator = [[AltAzComputation alloc] initWithRA:[transient.RightAscension doubleValue]
																		 DEC:[transient.Declination doubleValue] ];
	
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
	//Set the label
	cell.textLabel.text = [transient.EventType uppercaseString];
	
	//Set the label color
	cell.textLabel.textColor = textLabelColor;
	//Set the detail text label
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  Mv=%.1f", 
								 transient.AlertDate,
								 [transient.VisibleMagnitude floatValue]];
	
	//Here is where we get the row image.  Unlike EventListController we do not get the image from a cache, it is stored
	//with the event.  If we use different images in the future, they should also be stored with the event
	UIImage *image;
	if (![userDefaults boolForKey:kEventThumbnailsKey]) {
		image = [UIImage imageWithData:transient.CellImage];
	}else {
		image = [UIImage imageWithData:transient.ReferenceImage];
	}


	//Now that we have the image we must size it properly for display in the table
	CGSize newSize ;
	newSize.height = kTableViewRowHeight-5;
	newSize.width = kTableViewRowHeight-5;
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	//This retain is needed in order to avoid a release of a "pointer being freed was not allocated"
	//error.  According to the documentation UIGraphicsGetImageFromCurrentImageContext() returns
	//an autoreleased object but apparently there is no retain issued.
	[newImage retain];
	UIGraphicsEndImageContext();
	//put the image into the cell
	cell.imageView.image = newImage;
	
	//clean up memory
	[transient release];

	return cell;							  
	
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return kTableViewRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	//A cell was selected so we need to define a BookmarkDetailController and then pass the 
	//event object to the detail controller.
	Transient *transient = [fetchedResultsController objectAtIndexPath:indexPath];
	BookmarkDetailController *bookmarkDetailController = [[BookmarkDetailController alloc] 
													initWithNibName:@"BookmarkDetailView" bundle:nil];
	bookmarkDetailController.title = transient.EventType;
	
	bookmarkDetailController.hidesBottomBarWhenPushed = YES;
	bookmarkDetailController.transient = transient;
 
	
	[self.navController pushViewController:bookmarkDetailController animated:YES];
	[bookmarkDetailController release];
}

	
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//We will allow deletion of items
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete){
		[managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];

		// Save the context.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. 
			 You should not use this function in a shipping application, although it may be useful during development. 
			 If it is not possible to recover from the error, display an alert panel that instructs the user to 
			 quit the application by pressing the Home button.
			 */
			NSLog(@"BookmarkListController: Unresolved error %@, %@", error, [error userInfo]);
//			abort();
		}
//		[self setFooterForTableView];	
	}
	
	
}
										 
#pragma mark -
#pragma mark Fetched results controller
	

	
	/**
	 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
	 */
	
	- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
		// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
		[self.tableView beginUpdates];
	}
	
	
	- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
		UITableView *tableView = self.tableView;
		
		switch(type) {
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
				//		case NSFetchedResultsChangeUpdate:
				//			[self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
				//			break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				// Reloading the section inserts a new row and ensures that titles are updated appropriately.
				[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
	
	
	- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
		switch(type) {
			case NSFetchedResultsChangeInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
	
	
	- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
		// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
		[self.tableView endUpdates];
	}
	


@end
