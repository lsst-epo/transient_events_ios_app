//
//  SurveyQuestion3ViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 6/16/10.
//  Copyright 2010 Diffraction Limited Design LLC. All rights reserved.
//

#import "SurveyQuestion3ViewController.h"
#import "Constants.h"
#import "Transient_EventsAppDelegate.h"
#import "httpFlattening.h"
#import <QuartzCore/QuartzCore.h>


@implementation SurveyQuestion3ViewController
@synthesize	surveyResults;
@synthesize tintView;
@synthesize scrollView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = NSLocalizedString(@"Comments", @"Question 3 Page Title");
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.tintView.backgroundColor = kSettingsTableBackgroundColor;
//	UIBarButtonItem  *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//																		   target:self 
//																		   action:@selector(doneButtonPressed)];
	UIBarButtonItem  *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit",@"Submit")
																	  style:UIBarButtonItemStylePlain 
																	 target:self 
																	 action:@selector(doneButtonPressed)];
	self.navigationItem.rightBarButtonItem = done;
	[done release];
    
    
    self.tintView.layer.backgroundColor = [[UIColor colorWithWhite:0.1 alpha:0.75] CGColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {        
        self.tintView.layer.cornerRadius = 0.6;
        self.tintView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.tintView.layer.borderWidth = 0.7;
    }
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
	NSString *answer = [self.surveyResults objectForKey:kQuestion3Key];
	if (answer) {
		self.scrollView.text = answer;
	}
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self.scrollView resignFirstResponder];
	//Save the data to the dictionary object

	if (self.scrollView.text) {
		[self.surveyResults setObject:self.scrollView.text forKey:kQuestion3Key];

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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)doneButtonPressed{
#ifdef LOGGING
	NSLog(@"%@:, Done button pressed\n",[self class]);
#endif
	[self.scrollView resignFirstResponder];
#ifdef LOGGING
	NSLog(@"%@:, Comment Text:\n%@",[self class],self.scrollView.text);
#endif
	NSString *trimmedComment;
	NSInteger commentLength = [self.scrollView.text length];
	if (commentLength > kMaxCommentLength) {
		trimmedComment = [[NSString alloc] initWithString:[self.scrollView.text substringToIndex:kMaxCommentLength]];
	}else {
		trimmedComment = [[NSString alloc] initWithString:self.scrollView.text];
	}
	//Save the data to the dictionary object
	[self.surveyResults setObject:trimmedComment forKey:kQuestion3Key];
	[trimmedComment release];
	//Survey is now done so we want to send it to the server and then close out the survey.
	
	//Send here
	[self sendSurveyResultsSynchronously:NO];
	//Set the survey tries to number of tries + 1 so the next time the app is launched the user is
	//no longer reminded.
	[[NSUserDefaults standardUserDefaults] setInteger:kShowSurveyTab forKey:kTakeSurveyKey];
	[[[[UIApplication sharedApplication] delegate] tabBarController]setSelectedIndex:0];
	[[[UIApplication sharedApplication] delegate] removeLastTab];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)sendSurveyResultsSynchronously:(BOOL)synchronous{
	unsigned int	devTokenInt[8];
	id appDelegate = [[UIApplication sharedApplication] delegate];
	NSData *theDevToken = [[NSData alloc] initWithData:[appDelegate devToken]];
	[theDevToken getBytes:&devTokenInt];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kSurveyURL]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest addValue:@"/jsonQuery/" forHTTPHeaderField:@"action"];
	NSMutableString *formattedString = [NSMutableString stringWithFormat:@"deviceToken=%X,%X,%X,%X,%X,%X,%X,%X",
										CFSwapInt32(devTokenInt[0]),
										CFSwapInt32(devTokenInt[1]),
										CFSwapInt32(devTokenInt[2]),
										CFSwapInt32(devTokenInt[3]),
										CFSwapInt32(devTokenInt[4]),
										CFSwapInt32(devTokenInt[5]),
										CFSwapInt32(devTokenInt[6]),
										CFSwapInt32(devTokenInt[7])
										];
	
	//OK, now we need to append the survey results
	NSArray *keys = [self.surveyResults allKeys];
	for (NSString *key in keys){
			[formattedString appendFormat:@"&%@=%@",key,[[self.surveyResults objectForKey:key]escapedForQueryURL]];
	}
#ifdef LOGGING
	NSLog(@"%@: Formatted Post String=\n%@",[self class],formattedString);
#endif
	[formattedString replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [formattedString length])];
#ifdef LOGGING
	NSLog(@"%@: Formatted Post String=\n%@",[self class],formattedString);

#endif
	//Add the POST query to the message body
	NSString *bodyString = [[NSString alloc] initWithString:[formattedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	char buffer[[bodyString length]];
	NSUInteger usedLength;
	//put the bytes in a c-string buffer
	[bodyString getBytes:&buffer 
			   maxLength:[bodyString length] 
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
	if (synchronous) {
		//Synchronous communications were requested.  This is typically done from applicationWillTerminate 
		NSURLResponse *urlResponse = nil;
		NSError *error = nil;
		NSData *returnData = nil;
		//		NSLog(@"AppDelegate: Sending synchronous URL request to push server");
		returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
		NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
		if (error != nil) {
			NSLog(@"Unable to send synchronous survey request to LSST server");
			NSLog(@"AppDelegate: urlRequest sent to server\n returnData = %@\nurlResponse = %@\n,error = %@",
				  returnString, [urlResponse description], [error description]);
			
		}
		[returnString release];
	}else {
		//async connection requested
		NSURLConnection *urlConnection = nil;
		//		NSLog(@"AppDelegate: Sending asynchronous URL request to push server");
		
		urlConnection = [NSURLConnection connectionWithRequest: urlRequest delegate: self];
		if (urlConnection == nil) {
			NSLog(@"%@:  Unable to connect to LSST server with asynchronous request",[self class]);
		}
		
	}
	[theDevToken release];
	[urlRequest release];
}



- (void)dealloc {
	[surveyResults release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
#ifdef LOGGING
	NSLog(@"%@:, TextViewShouldEndEdting\n",[self class]);
#endif
	return YES;
}

@end
