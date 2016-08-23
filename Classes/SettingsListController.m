//
//  SettingsListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "SettingsListController.h"
#import "Constants.h"
#import "LocationSettingViewController.h"
#import "MagnitudeLimitViewController.h"
#import "EventAgeViewController.h"
#import "RAFormatListController.h"
#import "EventTypesListController.h"
#import "AboutTransientEventsView.h"
#import "MinimumAltitudeViewController.h"
#import "FinderImageWebViewController.h"


@implementation SettingsListController
@synthesize navController;
@synthesize groupTitles;
@synthesize userDefaults;
@synthesize titles;
@synthesize RAFormatArray;
@synthesize tableView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"Settings", @"Settings Page Title");
		self.tabBarItem.image = [UIImage imageNamed:@"Gear.png"];
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
	CGRect tableBounds = self.view.bounds;
	tableBounds.origin.y	 = 0;
	tableBounds.size.height = tableBounds.size.height - (48 + 44);
	self.tableView = [[UITableView alloc] initWithFrame:tableBounds style:UITableViewStyleGrouped];
	[self.tableView setBackgroundColor:kSettingsTableBackgroundColor];
	[self.view addSubview:self.tableView];

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}


/**
 performs initial settings once the view loads.  This includes reading the settings titles, group title and RAFormat
 entries from PLISTS.  They are read from plists to help localize the settings at some time in the future.
 
 NOTE:  The SettingsTitles.plist file contains an array of groups, each of which contains an array of titles.  The number
 of groups must match the number of groups listed in GroupTitle.plist.
 */

- (void)viewDidLoad {//! \private
	self.userDefaults = [NSUserDefaults standardUserDefaults];
	//Read in the setting titles plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"SettingsTitles" ofType:@"plist"];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
	self.titles = array;
	[array release];
	//Read in the group titles plist
	NSString *path2 = [[NSBundle mainBundle] pathForResource:@"GroupTitles" ofType:@"plist"];
	array = [[NSMutableArray alloc] initWithContentsOfFile:path2];
	self.groupTitles = array;
	//Read in the RAFormat titles plist
	NSString *arrayPath = [[NSBundle mainBundle] pathForResource:@"RAFormat" ofType:@"plist"];
	self.RAFormatArray = [[NSMutableArray alloc] initWithContentsOfFile:arrayPath];
	//Set up the table style
	UIColor *navBarColor = kNavBarColor;
	self.navController.navigationBar.tintColor=navBarColor;

//	self.tableView.backgroundColor = [UIColor darkGrayColor];
	self.tableView.separatorColor = [UIColor blackColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	//Set up the bar button items
	UIBarButtonItem *helpButton		= [[UIBarButtonItem alloc] initWithTitle:@"Help"
																	style:UIBarButtonItemStyleBordered
																   target:self 
																   action:@selector(displayHelp)];
	self.navigationItem.leftBarButtonItem  = helpButton;
	[helpButton	   release];
	

    [super viewDidLoad];
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

- (void)viewDidUnload {//! \private
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated{//! \private
	[self.tableView reloadData];
	[super viewDidAppear:animated];
}

/**
 sets the userDefault for key "kVisibleObjectsOnlyKey" and posts a kRefreshNotification
 */


- (void)visibleObjectsOnDidChangeState:(id)sender{//! \private
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:self]];
	UISwitch *switchView = (UISwitch *)sender;
	BOOL tempBool = switchView.on;
	[userDefaults setBool:tempBool forKey:kVisibleObjectsOnlyKey];

}

/**
 sets the userDefault for key "kEventThumbnailsKey" and posts a kRefreshNotification
 */


- (void)eventThumbnailsOnDidChangeState:(id)sender{//! \private
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:self]];
	UISwitch *switchView = (UISwitch *)sender;
	BOOL tempBool = switchView.on;
	[userDefaults setBool:tempBool forKey:kEventThumbnailsKey];	
}

/**
 sets the userDefault for key "kAlertsOnKey" 
 */


- (void)alertsOnDidChangeState:(id)sender{//! \private
	UISwitch *switchView = (UISwitch *)sender;
	BOOL tempBool = switchView.on;
	[userDefaults setBool:tempBool forKey:kAlertsOnKey];
	
}

- (void)displayHelp{//! \private
	//define the web view controller to be used to display help
	WebViewController *helpView = [[WebViewController alloc]
											  initWithNibName:@"FinderImageWebView"
											  bundle:nil];
	//tell the view not to scale the content, I already did the scaling in the design of the page.
	[helpView doNotScaleContentToFit];
	helpView.title = @"Help";
	//Tell the web view where to find the help file.
	[helpView webViewForURL:[[NSBundle mainBundle] pathForResource:kSettingsListHelpFile ofType:@"html"]];
	helpView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:helpView animated:YES];
	[helpView release];
	
}

- (void)dealloc {//! \private
	[tableView release];
	[navController release];
	[RAFormatArray release];
	[groupTitles release];
//	[userDefaults release];
	[titles release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{//! \private
	return [self.groupTitles count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{//! \private
	return [[self.titles objectAtIndex:section] count];	
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//Get the cell titles for this section
	NSArray *titleArray = [[NSArray alloc] initWithArray:[self.titles objectAtIndex:indexPath.section]];
	
	static NSString *SettingsCellIdentifier = @"SettingsCellIdentifier";
	//define the style of the cell
	UITableViewCell	*cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:SettingsCellIdentifier] autorelease];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = kSettingsTextLabelFont;
		cell.detailTextLabel.font = kSettingsDetailTextLabelFont;

		// creating background view manullay
		UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320, 44)];	
		// set it to the cell
		cell.backgroundView = backView;	
		// release it
		[backView release];
	}
	if (indexPath.row % 2 == 1) {
//		cell.contentView.backgroundColor = kTableOddRowColor;
		cell.backgroundView.backgroundColor = kTableSettingsTableOddRowColor;		
	}else{
//		cell.contentView.backgroundColor = kTableEvenRowColor;
		cell.backgroundView.backgroundColor = kTableEvenRowColor;
		
	}
	
	cell.textLabel.text = [[titleArray objectAtIndex:indexPath.row]uppercaseString];
	[titleArray release];
	//define a couple of strings we may need later
	NSString *day = NSLocalizedString(@"Day", @"Singular Day");
	NSString *days = NSLocalizedString(@"Days", @"Singular Days");
	//compute a rowCase number.  The rowCase is 100*section + row.  this lets us use 
	//a case statement to format each row.
	
	NSInteger rowCase = 100*indexPath.section + indexPath.row;
	UISwitch *switchView;
	
	//This case statement formats each row in the table view.  Note that it requires a list of 
	//constants, one per row and it requires a separate case statement for each row.
	//I wish apple would release the code they use to generate the settings defaults used in the
	//Settings.app.  I thought about writing something similar but I thought it might be a waste of time.
	switch (rowCase) {
		case kLocationCase:
				
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%5.4f%@, %5.4f%@", 
										 fabs([userDefaults floatForKey:kLocationLatitudeKey]), 
										 ([userDefaults floatForKey:kLocationLatitudeKey] >= 0 ? @"N" : @"S"),
										 fabs([userDefaults floatForKey:kLocationLongitudeKey]),
										 ([userDefaults floatForKey:kLocationLongitudeKey] >= 0 ? @"E" : @"W")];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.text = nil;
			cell.accessoryView = nil;
			break;
		case kMagnitudeLimitCase:
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%5.1f Vmag",
										 [userDefaults floatForKey:kLimitingMagnitudeKey]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.accessoryView = nil;
			
			break;
		case kEventTypesCase:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.text = nil;
			cell.accessoryView = nil;

			break;
		case kEventAgeCase:
			if ([userDefaults integerForKey:kEventAgeKey] == 1){
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",[userDefaults integerForKey:kEventAgeKey],day ];
			}else{
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@",[userDefaults integerForKey:kEventAgeKey],days ];
			}
			
//			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Days",
//										 [userDefaults integerForKey:kEventAgeKey]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.accessoryView = nil;
			
			break;
		case kMinAltitudeCase:
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d˚",
										 [userDefaults integerForKey:kMinAltitudeKey]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.accessoryView = nil;
			
			break;
			
		case kRAFormatCase:
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
										 [RAFormatArray objectAtIndex:[userDefaults integerForKey:kRAFormatKey]]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.accessoryView = nil;
			
			break;
			
		//The next three cases are for cells with switches.  Notice that we create the switch view
		//programmatically and then assign it to a selector.  For this reasin we do not need to define
		//the selectors with an IBACTION return type.  By doing this the selectors are called when
		//the switch changes state.
		case kVisibleObjectsOnlyCase:
			switchView = [[UISwitch alloc] init];
			switchView.tag = kVisibleObjectsOnlyCase;
			switchView.on = [userDefaults boolForKey:kVisibleObjectsOnlyKey];
			[switchView addTarget:self action:@selector(visibleObjectsOnDidChangeState:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchView;
			[switchView release];
			cell.detailTextLabel.text = nil;

			break;
		case kEventThumbnailsCase:
			switchView = [[UISwitch alloc] init];
			switchView.tag = kEventThumbnailsCase;
			switchView.on = [userDefaults boolForKey:kEventThumbnailsKey];
			[switchView addTarget:self action:@selector(eventThumbnailsOnDidChangeState:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchView;
			[switchView release];
			cell.detailTextLabel.text = nil;

			break;

		case kAlertsCase:
			switchView = [[UISwitch alloc] init];
			switchView.tag = kAlertsCase;
			switchView.on = [userDefaults boolForKey:kAlertsOnKey];
			[switchView addTarget:self action:@selector(alertsOnDidChangeState:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = switchView;
			[switchView release];
			cell.detailTextLabel.text = nil;
			
			break;
		case kAboutCase:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.text = nil;
			cell.accessoryView = nil;

			break;

		default:
			break;
	}

	return cell;
	
	
}



#pragma mark -
#pragma mark TableViewDelegate
/**
 By defining our own views for the headers we have more flexibility in header formatting.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{//! \private
	UILabel *headerLabel;
	
	headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 320, 50)]autorelease];
	headerLabel.text = [[groupTitles objectAtIndex:section]uppercaseString];
	headerLabel.font = kTextLabelFont;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.opaque = YES;
	headerLabel.backgroundColor = [UIColor clearColor];
	//	headerLabel.shadowOffset = CGSizeMake(0,1);
	headerLabel.textAlignment = UITextAlignmentCenter;
	//	headerLabel.shadowColor = [UIColor whiteColor];
	return headerLabel;
	
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//! \private
	return 50;
}

/**
 When a row is touch this method is called and the index path to the row is passed.  
 An integer rowCase is computed as 100*section + row.  This integer is used in a case
 statement to select the proper case for each row.  Each row (except simple switches)
 has its own entry in the case statement allowing each row to be handled in its own 
 unique manner.  In all cases handled in the case statement, a new view is instantiated
 and pushed onto the controller stack.  Other functions could also be performed if appropriate.
 If a row with a switch is touched this method is still called but it does not perform
 any action.  The switches in these rows all have target selectors which were set in the
 tableView:cellForRowAtIndexPath method.  These selectors are called directly when the
 switch changes state.
 
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	//define the rowCase  - now you see why I did this, it makes life a little easier.
	NSInteger rowCase = 100*indexPath.section + indexPath.row;
	UIViewController *nextView;
	

	
	switch (rowCase) {
		case kLocationCase:
			nextView = [[LocationSettingViewController alloc] initWithNibName:@"LocationView" bundle:nil];
			nextView.hidesBottomBarWhenPushed = YES;

			[(SettingsListController *)nextView setNavController:self.navController];
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			break;
		case kMagnitudeLimitCase:
			nextView = [[MagnitudeLimitViewController alloc] initWithNibName:@"MagnitudeLimitView" bundle:nil];
			nextView.hidesBottomBarWhenPushed = YES;
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			break;
		case kEventTypesCase:
			nextView = [[EventTypesListController alloc] init];
			nextView.hidesBottomBarWhenPushed = YES;			
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			
			break;
		case kEventAgeCase:
			nextView = [[EventAgeViewController alloc] initWithNibName:@"EventAgeViewController" bundle:nil];
			nextView.hidesBottomBarWhenPushed = YES;
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			break;
		case kMinAltitudeCase:
			nextView = [[MinimumAltitudeViewController alloc] initWithNibName:@"MinAltitudeView" bundle:nil];
			nextView.hidesBottomBarWhenPushed = YES;
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			break;
		case kRAFormatCase:
			nextView = [[RAFormatListController alloc] init];
			nextView.hidesBottomBarWhenPushed = YES;
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			break;
		case kVisibleObjectsOnlyCase:
//			cell = [self.tableView cellForRowAtIndexPath:indexPath];
//			switchView = (UISwitch *) [cell viewWithTag:kVisibleObjectsOnlyCase];
//			BOOL tempBool = switchView.on;
//			[userDefaults setBool:switchView.on forKey:kVisibleObjectsOnlyKey];
			
			break;
		case kAlertsCase:
			
			break;
		case kAboutCase:
			nextView = [[AboutTransientEventsView alloc] initWithNibName:@"AboutTransientEventsView" bundle:nil];
			nextView.hidesBottomBarWhenPushed = YES;
			[self.navController pushViewController:nextView animated:YES];
			[nextView release];
			
			break;
		default:
			break;
	}
}

@end
