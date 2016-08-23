    //
//  SurveyQuestion2ViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import "SurveyQuestion2ViewController.h"
#import "Constants.h"
#import "SurveyQuestion3ViewController.h"

@implementation SurveyQuestion2ViewController
@synthesize	selectedButton;
@synthesize nextButton;
@synthesize navController;
@synthesize surveyResults;
@synthesize	tintView;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = NSLocalizedString(@"Question 2", @"Question 2 Page Title");
		self.selectedButton = nil;
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

- (void)viewWillAppear:(BOOL)animated{
	NSString *answer = [self.surveyResults objectForKey:kQuestion2Key];
	if (answer) {
		NSArray	*answers = [answer componentsSeparatedByString:@","];
		NSArray *subviews = [self.view subviews];
		for (id object in subviews) {
			if ([object isKindOfClass:[UIButton class]]) {
				NSString *currentTitle = [object  titleForState:UIControlStateNormal];
				for (NSString *string in answers){
					if ([currentTitle isEqualToString:string]) {
						[object setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
						UIBarButtonItem  *nextQuestion = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Final Question",@"Final Question")
																						  style:UIBarButtonItemStylePlain 
																						 target:self 
																						 action:@selector(nextButtonPressed)];
						
						self.navigationItem.rightBarButtonItem = nextQuestion;
						[nextQuestion release];

						[object setBackgroundColor:kSelectedSurveyButtonBackgroundColor];
						
						
					}
				}
				
			}
		}
		
	}
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	//moving to the another screen, save the results and move on.
	NSArray *subviews = [self.view subviews];
	NSMutableString *answers = [[NSMutableString alloc] init];
	for (id object in subviews) {
		if ([object isKindOfClass:[UIButton class]]) {
#ifdef LOGGING
			NSLog(@"%@: ObjectWithClass %@",[self class],[object  titleColorForState:UIControlStateNormal]);
#endif	
			if ([object  titleColorForState:UIControlStateNormal] == [UIColor whiteColor]) {
				[answers appendFormat:@"%@,",[object currentTitle]];
			}
			
		}
	}
	[answers appendString:@"END"];
#ifdef LOGGING
	NSLog(@"%@, Uses: %@",[self class],answers);
#endif
	
	[self.surveyResults setObject:answers forKey:kQuestion2Key];
#ifdef LOGGING
	NSLog(@"%@, surveyResults: %@",[self class],[self.surveyResults description]);
#endif
	
	[super viewWillDisappear:animated];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)buttonPressed:(id)sender{
#ifdef LOGGING
	NSLog(@"SurveyQuestion1ViewController%@: User pressed button with title %@",[self class],[sender currentTitle]);
#endif
#ifdef LOGGING
	NSLog(@"SurveyQuestion1ViewController%@: User pressed button with title %@",[self class],[sender currentTitle]);
#endif
	if ([sender titleColorForState:UIControlStateNormal] == [UIColor whiteColor]) {
		[sender setTitleColor:kSurveyItemTextColor forState:UIControlStateNormal];
		if ([sender tag]%2) {
			[sender setBackgroundColor:kOddSurveyButtonBackgroundColor];
		}else{
			[sender setBackgroundColor:kEvenSurveyButtonBackgroundColor];
		}
		
	}else {
		[sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[sender setBackgroundColor:kSelectedSurveyButtonBackgroundColor];
	}
	
	UIBarButtonItem  *nextQuestion = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Final Question",@"Final Question")
																	  style:UIBarButtonItemStylePlain 
																	 target:self 
																	 action:@selector(nextButtonPressed)];
	
	self.navigationItem.rightBarButtonItem = nextQuestion;
	[nextQuestion release];
	self.nextButton.hidden = NO;
}

- (IBAction)nextButtonPressed{
#ifdef LOGGING
	NSLog(@"SurveyQuestion2ViewController: Next button pressed");
#endif
	
	SurveyQuestion3ViewController *nextView= [[SurveyQuestion3ViewController alloc] initWithNibName:@"SurveyQuestion3ViewController"
																							 bundle:nil];
	nextView.surveyResults = self.surveyResults;
	[self.navController pushViewController:nextView animated:YES];
	[nextView release];
	
	
}

- (void)dealloc {
	[selectedButton release];
	[surveyResults release];
    [super dealloc];
	
}


@end