//
//  EventTypesListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "EventTypesListController.h"
#import "Constants.h"

@implementation EventTypesListController

@synthesize	list;
@synthesize	userDefaults;
@synthesize	eventDictionary;
@synthesize backupEventDictionary;
@synthesize tableView;

/**
 @brief default initializer
 
 Gets the pointer to userDefaults and gets a backup copy of the eventDictionary.
 
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Event Types", @"Event Types Page Title");
		self.userDefaults = [NSUserDefaults standardUserDefaults];
		self.backupEventDictionary = [[NSMutableDictionary alloc] initWithDictionary:[userDefaults objectForKey:kEventTypesKey]];

		
    }
    return self;
}

/**
 @brief sets the background image and instantiates the table view
 
 
 */

- (void)loadView {
	[super loadView];
	
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [imageView setImage:[UIImage imageNamed:@"BGStar_Big.jpg"]];
    }
    else
    {
        [imageView setImage:[UIImage imageNamed:@"BGStar.jpg"]];
    }
	[self.view addSubview:imageView];
	CGRect tableBounds = self.view.bounds;
	tableBounds.origin.y	 = 0;
	tableBounds.size.height = tableBounds.size.height - (44);
	[self.tableView = [UITableView alloc] initWithFrame:tableBounds style:UITableViewStyleGrouped];
	[self.tableView setBackgroundColor:kSettingsTableBackgroundColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.backgroundView.alpha = 0.5;
    }
	[self.view addSubview:self.tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}


/**
 loads in the eventDictionary from user defaults using kEventTypesKey. All of the keys are then
 extracted from this dictionary and sorted into the list array.  This array is used for the tableView 
 display.  
 
 Also sets the style of the table view.
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {//! \private
	
	self.eventDictionary = [[NSMutableDictionary alloc] initWithDictionary:[userDefaults objectForKey:kEventTypesKey]];
	
 
	
	NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[eventDictionary allKeys] 
																   sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	self.list = array;
	[array release];
	
	//	set the table style
	self.tableView.backgroundColor = kSettingsTableBackgroundColor;
	self.tableView.separatorColor = [UIColor blackColor];
	
    [super viewDidLoad];
}


- (void)dealloc{//! \private
	[eventDictionary release];
	[backupEventDictionary release];
	[tableView release];
	[list release];
	[super dealloc];
}

/**
 @brief checks state when view goes offscreen
 
 Checks to make sure that at least one event has been selected.  If
 all events have been deselected the state of the event dictionary upon
 entering is restored and an alert is presented.
 
 
 */
- (void)viewWillDisappear:(BOOL)animated{//! \private
	NSArray *keys = [[NSArray alloc] initWithArray:[self.eventDictionary allKeys]];
	int enableEventCount = 0;
	//count the number of enabled events
	for (NSString *key in keys) {
		if ([[self.eventDictionary objectForKey:key]boolValue]) {
			enableEventCount++;
		}
	}
	[keys release];
	if (enableEventCount == 0) {//there were no enabled events, restore the event dictionary and put up an alert
		[userDefaults setObject:self.backupEventDictionary forKey:kEventTypesKey];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Events Selected",@"No Events Selected")
														message:NSLocalizedString(@"At least one event must be selected. Your changes will not be saved.", @"Changes not saved")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	[super viewWillDisappear:animated];

}



#pragma mark -
#pragma mark TableViewDataSource

/**
 Currently there is only on section in this table.  If we add more event feeds we may want to rethink
 this and categorize the events in some way.
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{//! \private
	return 1;
}

/**
 This is a simple table view so the number of rows is just the number of items in the list array
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{//! \private
	return [self.list count];	
}

/**
 Create the cells for the table view.  For each cell the entry in the list array corresponding to the current
 row is extracted and set as the textLabel.  This same text is used to find the corresponding entry in the
 eventDictionary.  If that entry is YES a checkmark is displayed in the cell.
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//! \private
	static NSString *EventTypesCellIdentifier = @"EventTypesCellIdentifier";
	//format the cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventTypesCellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:EventTypesCellIdentifier] autorelease];
		
		cell.textLabel.font = kDetailTextLabelFont;
		cell.backgroundColor = [UIColor clearColor];
		
		// creating background view manullay
		UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320, 44)];	
		// set it to the cell
		cell.backgroundView = backView;	
		// release it
		[backView release];
	}
	if (indexPath.row % 2 == 1) {
		//cell.contentView.backgroundColor = kSettingsTableBackgroundColor;
		cell.backgroundView.backgroundColor = kTableSettingsTableOddRowColor;		
	}else{
		//cell.contentView.backgroundColor = kTableEvenRowColor;
		cell.backgroundView.backgroundColor = kTableEvenRowColor;
		
	}
	
	//get the cell label from the corresponding entry in the list array
	cell.textLabel.text = [[list objectAtIndex:indexPath.row]uppercaseString];
	//Look for this entry in the event dictionary.  If it is YES, set a checkmark in the cell.
	if ([[eventDictionary objectForKey:[list objectAtIndex:indexPath.row] ] boolValue]){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

/**
 Handles a row selection.  When a row is selected the row number is used to extract the event name for that 
 row number from the list array.  This string is used as the key in the event dictionary.  The current
 state of this key is obtained from the dictionary and then it is toggled to the opposite state.  The
 userDefaults are updated with this changed dictionary and the table view is told to reload.
 
 Finally, the kReloadNotification is posted since a change in event types requires a that we update 
 our event list from the server.  The event list will be updated the next time the event tab is selected.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{//! \private
	//Get the name of the event in the selected row
	NSString *key = [[NSString alloc] initWithString:[list objectAtIndex:indexPath.row]];
	//Use the name of the event as a key and get the current state
	BOOL value = [[self.eventDictionary objectForKey:key] boolValue];
	//toggle the state
	value = (value ? NO : YES);
	//write the state back into the eventDictionary and upate userDefaults database.
	[self.eventDictionary setValue:[NSNumber numberWithBool:value] forKey:key];
	[userDefaults setValue:self.eventDictionary forKey:kEventTypesKey];
	[tableView reloadData];
	//post the notification that the event list data needs to be reloaded from the server.
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kReloadNotification object:self]];

}
@end
