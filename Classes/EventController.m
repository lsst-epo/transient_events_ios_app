//
//  EventController.m
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "EventController.h"
#import "EventListController.h"

@implementation EventController
@synthesize navController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Events";
		self.tabBarItem.image = [UIImage imageNamed:@"EventIcon.png"];
//	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0]autorelease];
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Events";
	self.navController.tabBarItem.image = [UIImage imageNamed:@"EventIcon.png"];

	EventListController *eventListController = [[EventListController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:eventListController];
	eventListController.navController = aNavController;
	self.navController = aNavController;
	self.navController.navigationBar.barStyle = UIBarStyleBlack;
	[eventListController release];
	[aNavController release];
	[self.view addSubview:self.navController.view];
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


- (void)dealloc {
	[navController release];
    [super dealloc];
}


@end
