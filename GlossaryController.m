//
//  GlossaryController.m
//  Transient Events
//
//  Created by Nathan Fitzgibbon on 12/7/11.
//  Copyright (c) 2011 Diffraction Limited Design LLC. All rights reserved.
//

#import "GlossaryController.h"
#import "Constants.h"
#import "GlossaryView.h"

@implementation GlossaryController
@synthesize navController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //set the page title
        self.title = NSLocalizedString(@"Glossary", @"Glossary Page Title");
        //Set the icon for the tab bar for the Info List
        self.tabBarItem.image = [UIImage imageNamed:@"152-rolodex.png"];    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIColor *navBarColor = kNavBarColor;
	self.navController.navigationBar.tintColor=navBarColor;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
  
    //Initialize the array.
    listOfItems = [[NSMutableArray alloc] init];
    
    //Add items
    [listOfItems addObject:@"Active Galactic Nucleus"];
    [listOfItems addObject:@"Asteroid"];
    [listOfItems addObject:@"Blazar Outburst"];
    [listOfItems addObject:@"Cataclysmic Variable"];
    [listOfItems addObject:@"Comet"];
    [listOfItems addObject:@"Eclipsing Variable"];
    [listOfItems addObject:@"Gamma Ray Burst Afterglow"];
    [listOfItems addObject:@"High Proper Motion Star"];
    [listOfItems addObject:@"Microlensing"];
    [listOfItems addObject:@"Mira Variable"];
    [listOfItems addObject:@"Nova"];
    [listOfItems addObject:@"Planetary Microlensing"];
    [listOfItems addObject:@"RR Lyrae Variable"];
    [listOfItems addObject:@"Supernova"];
    [listOfItems addObject:@"Transient Event"];
    [listOfItems addObject:@"Tidal Disruption Flare"];
    [listOfItems addObject:@"Unknown"];
    [listOfItems addObject:@"UV Ceti Variable"];
    [listOfItems addObject:@"Variable"];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [listOfItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    
    static NSString *cellIndentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell ==nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier]autorelease];
        
    }
    
    cell.textLabel.text =[listOfItems objectAtIndex:indexPath.row];
    return cell;
    
    
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     GlossaryView *objInfopage = [[GlossaryView alloc] initWithNibName:@"GlossaryView" bundle:nil];
     objInfopage.title =[listOfItems objectAtIndex:indexPath.row];
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:objInfopage animated:YES];
     [objInfopage release];
     
}

- (void)dealloc {
    
    [listOfItems release];
    [super dealloc];
}
@end
