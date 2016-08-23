//
//  SurveyQuestion1ViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import "SurveyQuestion1ViewController.h"
#import	"Constants.h"
#import	"SurveyQuestion2ViewController.h"



@implementation SurveyQuestion1ViewController
@synthesize	selectedButton;
@synthesize nextButton;
@synthesize navController;
@synthesize surveyResults;
@synthesize	tintView;
@synthesize tabBarController;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = NSLocalizedString(@"Survey", @"Survey Page Title");
		self.tabBarItem.image = [UIImage imageNamed:@"surveyIcon.png"];
		self.selectedButton = nil;
		self.nextButton.enabled = NO;
		self.nextButton.hidden = YES;
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
		self.surveyResults = dictionary;
		[dictionary release];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.tintView.backgroundColor = kSettingsTableBackgroundColor;
	UIColor *navBarColor = kNavBarColor;
	self.navController.navigationBar.tintColor=navBarColor;
	self.navController.navigationBar.barStyle = UIBarStyleBlack;
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated{
	self.tabBarController = [[[UIApplication sharedApplication] delegate]tabBarController];
//	self.tabBarController.tabBar.hidden = YES;
	NSString *answer = [self.surveyResults objectForKey:kQuestion1Key];
	if (answer) {
		NSArray *subviews = [self.view subviews];
		for (id object in subviews) {
			if ([object isKindOfClass:[UIButton class]]) {
				if ([[object  titleForState:UIControlStateNormal] isEqualToString:answer]) {
					self.selectedButton = object;
					[self.selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				}
				
			}
		}
		
	}
	[super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)buttonPressed:(id)sender{
#ifdef LOGGING
	NSLog(@"SurveyQuestion1ViewController%@: User pressed button with title %@",[self class],[sender currentTitle]);
#endif
	if (self.selectedButton !=nil){
		[self.selectedButton setTitleColor:[sender titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
		if (self.selectedButton.tag%2) {
			self.selectedButton.backgroundColor = kOddSurveyButtonBackgroundColor;
		}else {
			self.selectedButton.backgroundColor = kEvenSurveyButtonBackgroundColor;
		}

	}
	self.selectedButton = sender;

	[sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sender setBackgroundColor:kSelectedSurveyButtonBackgroundColor];
	UIBarButtonItem  *nextQuestion = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next Question",@"Next Question")
																	  style:UIBarButtonItemStylePlain 
																	target:self 
																	 action:@selector(nextButtonPressed)];
	
	self.navigationItem.rightBarButtonItem = nextQuestion;
	[nextQuestion release];
	self.nextButton.hidden = NO;
	
}

- (IBAction)nextButtonPressed{
#ifdef LOGGING
	NSLog(@"SurveyQuestion1ViewController: Next button pressed");
#endif
	//moving to the next screen, save the results and move on.
	[self.surveyResults setObject:[self.selectedButton currentTitle] forKey:kQuestion1Key];
	SurveyQuestion2ViewController *nextView= [[SurveyQuestion2ViewController alloc] initWithNibName:@"SurveyQuestion2ViewController"
																									bundle:nil];
	nextView.surveyResults = self.surveyResults;
	nextView.navController = self.navController;
	[self.navController pushViewController:nextView animated:YES];
	[nextView release];
	
	
}

- (void)dealloc {
	[selectedButton release];
	[tabBarController release];
	[surveyResults release];
    [super dealloc];
	
}


@end
