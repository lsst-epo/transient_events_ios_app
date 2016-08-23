//
//  LocationListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 10/8/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "LocationListController.h"
#import "Locations.h"
#import "Constants.h"


@implementation LocationListController

@synthesize	managedObjectContext;
@synthesize locationArray;
@synthesize fetchedResultsController;
@synthesize searchBar;
@synthesize tableView;
@synthesize baseBar;

/**
 @brief Initializes and returns a pointer to the object
 
 This also sets the page title and gets a pointer to the managedObjectContext
 
 
 */
- (id)init {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super init]) {
		self.title = NSLocalizedString(@"Locations", @"Locations");
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
	[imageView setImage:[UIImage imageNamed:kTableViewBackgroundImage]];
	[self.view addSubview:imageView];
	CGRect tableBounds = self.view.bounds;
	tableBounds.origin.y	 = 0;
	tableBounds.size.height = tableBounds.size.height - (44);
	[self.tableView = [UITableView alloc] initWithFrame:tableBounds style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:kSettingsTableBackgroundColor];
	[self.view addSubview:self.tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

/**
 @brief Initializes the view
 
 Sets the style for the table view, initializes the search bar, fetches the sorted list of locations from 
 the CoreData store and sets the search bar as the table header.
 
 */
- (void)viewDidLoad {//! \private

	self.tableView.backgroundColor = kSettingsTableBackgroundColor;
	self.tableView.separatorColor = [UIColor whiteColor];
	UISearchBar *bar = [[UISearchBar alloc] initWithFrame:
						CGRectMake(0, 0, 295, 44)];
	bar.autocorrectionType =UITextAutocorrectionTypeNo;
	UIColor *barColor = kNavBarColor;
	bar.tintColor = barColor;
	bar.delegate = self;

	[bar setShowsCancelButton:YES];
	
	UINavigationBar *barView = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)]; 
	barView.tintColor = barColor;
	[barView addSubview:bar];
	self.baseBar = barView;
	
	self.searchBar = bar;
	[bar release];
	[barView release];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Locations"
											  inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"Name" ascending:YES
										selector:@selector(localizedCaseInsensitiveCompare:)
										];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	[request setSortDescriptors:sortDescriptors];
	[request setIncludesPendingChanges:YES];
	[sortDescriptor release];
	[sortDescriptors release];
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
											  initWithFetchRequest:request
											  managedObjectContext:managedObjectContext
											  //sectionNameKeyPath:@"nameInitial"
												sectionNameKeyPath:@"SectionName"
											  cacheName:@"LocationCache"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"Fetch Error: %@",[error localizedDescription]);
	}
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request
																			  error:&error] mutableCopy];
	if (error) {
		NSLog(@"Fetch Error: %@",[error localizedDescription]);
	}else{
		[self setLocationArray:mutableFetchResults];
	}
	
//	self.tableView.tableHeaderView = searchBar;
	self.tableView.tableHeaderView = baseBar;
	
	[mutableFetchResults release];
	[request release];
	    [super viewDidLoad];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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

- (void)viewDidUnload {//! \private
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods
/**
 @brief Returns the number of sections in the table.
 
 This is a very simple method, it simply asks the fetched results controller to 
 count the number of sections and returns the number (unless there are 0 sections in
 which case it returns 1)
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {//! \private
	NSUInteger count = [[fetchedResultsController sections] count];
    if (count == 0) {
        count = 1;
    }
    return count;
	
}

/**
 @brief Returns the number of rows in each section
 
 This gets the section in question from the fetched results controller and asks it for a count of the 
 number of objects. The count of objects in the section is returned.
 */

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {//! \private
	if ([[fetchedResultsController sections] count] == 0) {
		return 0;
	}
//	if (section == 0){
//		return 0;
//	}
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

/**
 @brief Returns an array containing the sorted list of section titles.
 
 
 */

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView { //! \private
	return [fetchedResultsController sectionIndexTitles];
}

/**
 @brief Returns the title for a particular section
 
 This simply returns the name of a section, which in our case is the letter in the alphabet 
 which starts the section.
 
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {//! \private
	if ([[fetchedResultsController sections] count] == 0) {
		return nil;
	}
//	if (section == 0) {
//		return nil;
//	}

	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo name];


}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {//! \private
	return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}



/**
 @brief Returns the formatted table cell for an entry in the database
 
 The table cell contains the name of the location as the main text label and the latitude and longitude
 as the subtitle.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {//! \private
    
    static NSString *CellIdentifier = @"Cell";
    //format the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = kSettingsTextLabelFont;
		cell.textLabel.textColor = kLocationListTextLabelColor;
		cell.textLabel.adjustsFontSizeToFitWidth = NO;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.font = kDetailTextLabelFont;
		cell.detailTextLabel.textColor = kLocationListDetailTextLabelColor;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = NO;
		

    }
	
	
	//set the text lable and the detail label
	Locations *location = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[location Name]uppercaseString];
	NSString *detailLabel = [[NSString alloc] initWithFormat:@"%5.4f%@, %5.4f%@", 
							 fabs([location.Latitude floatValue]), 
							 ([location.Latitude floatValue]>= 0 ? @"N" : @"S"),
							 fabs([location.Longitude floatValue]),
							 ([location.Longitude floatValue]>= 0 ? @"E" : @"W")];
	cell.detailTextLabel.text = detailLabel;
	[detailLabel release];
	
    return cell;
}

/**
 @brief Handles the selection of a location in the table.
 
 When the user touches a row, the Longitude, Latitude, altitude and location name are entered into
 the user defaults database and a checkmark is placed next to the selected name.
 
 The object also sends a kRefreshNotification telling the event and detail list controllers that they 
 need to reload their tables in order to make sure the colors are updated.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {//! \private
	//Get the location displayed in the table row
	Locations *location = [fetchedResultsController objectAtIndexPath:indexPath];
	//get a pointer to user defaults
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//Update the location information in user defaults
	[userDefaults setObject:location.Name forKey:kLocationNameKey];
	[userDefaults setDouble:[location.Longitude doubleValue] forKey:kLocationLongitudeKey];
	[userDefaults setDouble:[location.Latitude doubleValue] forKey:kLocationLatitudeKey];
	[userDefaults setDouble:[location.Altitude doubleValue] forKey:kLocationAltitudeKey]; 
	//get a pointer to the cell and set the checkmark property.
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType=UITableViewCellAccessoryCheckmark;
	//send out the refresh notification.
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:self]];
	

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/**
 @brief Tells the table view that deleting rows is allowed.
 
 
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{//! \private
	return UITableViewCellEditingStyleDelete;
}

/**
 @brief handles the deletion of a row
 
 The managedObjectContext is told to delete the row at the particular index path and then the managedObjectContext is saved.
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{//! \private
	if (editingStyle == UITableViewCellEditingStyleDelete){
		[managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
		
	
}


- (void)dealloc {//! \private
	[managedObjectContext release];
	[fetchedResultsController release];
	[locationArray release];
	[searchBar release];
	[tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller
	
	
/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {//! \private
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {//! \private
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


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {//! \private
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {//! \private
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark  -
#pragma mark UISearchBarDelegate
/**
 @brief Handles typing in the search bar
 
 Performs a live search as the text is typed.  This is done by updating the NSPredicate with the new text.
 This all happens very fast so it can be done for each letter typed.
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {//! \private
//	NSLog(@"search > %@", searchText);
	//set up a fetch request for Location entities
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Locations" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	// set up a sort descriptor to order the events by name
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"Name" ascending:YES
										selector:@selector(localizedCaseInsensitiveCompare:)
										];
										NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	
	//Get the text from the search bar and use it to form an NSPredicate.  Add the predicate to the fetch request
	if (self.searchBar.text !=nil)
	{
		NSPredicate *predicate =[NSPredicate predicateWithFormat:@"Name contains[cd] %@", self.searchBar.text];
		[request setPredicate:predicate];
		
	}
	// Execute the fetch -- create a mutable copy of the result.
										NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
																								 initWithFetchRequest:request
																								 managedObjectContext:managedObjectContext
																								 //sectionNameKeyPath:@"nameInitial"
																								 sectionNameKeyPath:@"SectionName"
																								 cacheName:@"LocationCache"];
										aFetchedResultsController.delegate = self;
										self.fetchedResultsController = aFetchedResultsController;
										[aFetchedResultsController release];
										
										NSError *error = nil;
										[fetchedResultsController performFetch:&error];
										if (error) {
											NSLog(@"Fetch Error: %@",[error localizedDescription]);
										}
										;
	[request release];	
	
	[self.tableView reloadData];
}

/**
 @brief Handle the press of the cancel button in the search bar
 
 A fetch request is formed with a sort descriptor but no predicate and the fetch is executed
 to retrieve the entire list.  The table view is told to reload.  Also, the text in the search
 bar is cleared and the search bar resignsFirstResponder to make the keyboard go away.
 */

- (void)searchBarCancelButtonClicked:(UISearchBar *)theBar{//! \private
	//form a fetch request with a sort descriptor but no predicate
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Locations"
											  inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"Name" ascending:YES
										selector:@selector(localizedCaseInsensitiveCompare:)
										];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	[request setSortDescriptors:sortDescriptors];
	[request setIncludesPendingChanges:YES];
	[sortDescriptor release];
	[sortDescriptors release];
	//execute the fetch
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
															 initWithFetchRequest:request
															 managedObjectContext:managedObjectContext
															 //sectionNameKeyPath:@"nameInitial"
															 sectionNameKeyPath:@"SectionName"
															 cacheName:@"LocationCache"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	[aFetchedResultsController release];
	//check for a fetch error
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"Fetch Error: %@",[error localizedDescription]);
	}
	//Tell the search bar to put away the keyboard and clear the text
	[theBar resignFirstResponder];
	theBar.text = @"";
	//tell the table view to reload.
	[self.tableView reloadData];
	[request release];
}
/**
 @brief Handle a press of the search button.
 
 Since the search was done live there is not much to do except tell the search bar
 to resignFirstResponder.
 
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)theBar{//! \private
	[theBar resignFirstResponder];
}

@end

