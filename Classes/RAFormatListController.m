//
//  RAFormatListController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "RAFormatListController.h"
#import "Constants.h"


@implementation RAFormatListController

@synthesize	list;
@synthesize	userDefaults;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {//! \private
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = NSLocalizedString(@"RA Format", @"RA Format Page Title");

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
 Reads the list of RA format types from RAFormat.plist.  Sets the style of the table view.
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad { //! \private
	self.userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"RAFormat" ofType:@"plist"];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
	self.list = array;
	[array release];
	

	
//	self.navController.navigationBar.barStyle = UIBarStyleBlack;
	self.tableView.backgroundColor = kSettingsTableBackgroundColor;
	self.tableView.separatorColor = [UIColor blackColor];
	
    [super viewDidLoad];
}


- (void)dealloc{//! \private
	[list release];
	[super dealloc];
	[tableView release];
}



#pragma mark -
#pragma mark TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{//! \private
	return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{//! \private
	return [self.list count];	
}

/**
creates and formats table cells for display.  If the RA style of a particular cell is 
 recorded in userDefaults, that cell is marked with a checkmark.
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{//! \private
	static NSString *RAFormatCellIdentifier = @"RAFormatCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RAFormatCellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:RAFormatCellIdentifier] autorelease];
		
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
		//		cell.contentView.backgroundColor = kTableOddRowColor;
		cell.backgroundView.backgroundColor = kTableSettingsTableOddRowColor;		
	}else{
		//		cell.contentView.backgroundColor = kTableEvenRowColor;
		cell.backgroundView.backgroundColor = kTableEvenRowColor;
		
	}
	
	cell.textLabel.text = [[list objectAtIndex:indexPath.row] uppercaseString];
	if (indexPath.row == [userDefaults integerForKey:kRAFormatKey]){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

/**
 Handles the selection of a cell.  In this case, if a cell is selected the number of the 
 row is stored in userDefaults and the table view is told to reload.  When the tableView
 is reloaded the row number stored in userDefaults will display a checkmark.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{//! \private
	[userDefaults setInteger:indexPath.row forKey:kRAFormatKey];
	[tableView reloadData];
}
@end
