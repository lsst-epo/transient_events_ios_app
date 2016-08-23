//
//  AboutTransientEventsView.m
//  Transient Events
//
//  Created by Bruce E Truax on 10/6/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "AboutTransientEventsView.h"
#import	"Constants.h"

#define kDate	__DATE__
#define kTime	__TIME__

@implementation AboutTransientEventsView
@synthesize	versionNumber;
@synthesize	buildDate;
@synthesize	creditsWebView;
@synthesize scrollTimer;
@synthesize scrollPosition;
@synthesize tintView;

 /** 
  The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
*/
  - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Transient Events";
    }
    return self;
}



/**
 Gets the version string CFBundleShortVersionString and the build number CFBundleVersion from the 
 mainBundle infoDictionary.  The version string is updated manually in the info.plist file.  The 
 CFBundleVersion is updated automatically by the build script and is set equal to the current
 subversion revision number.
 
 After getting the version information the build date and time are extracted from the constants and
 formatted for display.
 
 Finally the mainBundle file Credits.html is passed to the web view.
 */
- (void)viewDidLoad {
	//Get the infoDictionary which is a dictionary created from the info.plist file
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	//extract the version information and put it into a nicely formatted string.
	NSString *versionString = [[NSString alloc] initWithFormat:@"%@ (%@)",[infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
	//update the versionNumber UILabel.
	versionNumber.text = [NSString stringWithFormat:@"%@ %@",kBuildStyle, versionString];

	versionNumber.font = kSettingsDetailTextLabelFont;
	[versionString release];
	//Get the date and time from the constants and put them in a nicely formatted string.
	NSString *dateString = [[NSString alloc] initWithFormat:@"%s, %s",kDate,kTime];
	//update the buildDate UILabel.
	buildDate.text = dateString;
	buildDate.font = kSettingsDetailTextLabelFont;
	//Get the credits HTML file.
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
    NSLog(@"%@", path);
	//Create a URL from the path
	NSURL *url = [NSURL fileURLWithPath:path];
	//Create a urlRequest from the URL
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	//Roll the credits!
	[creditsWebView setDelegate:self];
	[creditsWebView loadRequest:urlRequest];
	self.tintView.backgroundColor = kSettingsTableBackgroundColor;
	[dateString release];
//	NSLog(@"AboutTransientsView: Build Style is %@\nUse %@ Notification Server",kBuildStyle, kNotificationServer);
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

- (IBAction)touchedLSST:(id)sender{

	NSString *theURLString = [[NSString alloc] initWithFormat:@"http://www.lsst.org"];
	UIApplication *theApplication = [UIApplication sharedApplication];	
	//Check and see if we can handle this URL, if it is a phone we can.
	if ([theApplication canOpenURL:[NSURL URLWithString:[theURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]])
		[theApplication openURL:[NSURL URLWithString:[theURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	[theURLString release];
	
}

- (void)dealloc {
	[versionNumber release];
	[buildDate release];
	[creditsWebView release];
    [super dealloc];
}

/**
 Called by the scrollTimer every 0.1 second and scrolls the view by 1 pixel.
 If the scrollY position is different from the scrollPosition by nore than 1
 pixel then either the bottom of the page has been reached or the user has 
 manually scrolled the page.  In either case the timer is invalidated and the
 scrollPosition is set to -1.  
 
 
 */
- (void)scrollAPixel:(NSTimer *)aTimer{
	//Check to see if we need to continue scrolling.
	if (abs(scrollPosition - [[self.creditsWebView stringByEvaluatingJavaScriptFromString:@"window.scrollY"] intValue])> 1) {
		//no need to continue scrolling.  Invalidate timer and set scroll position to -1 so that the 
		//last scrollTo is not executed.
		[scrollTimer invalidate];
		scrollPosition = -1;
	}
	//Now check to see if we need to scroll.  If we did not do this check the screen would jump after a 
	//manual scroll.
	if (scrollPosition > -1) {
		NSString *script = [[NSString alloc] initWithFormat:@"window.scrollTo(0,%i)",scrollPosition];
		[self.creditsWebView stringByEvaluatingJavaScriptFromString:script];
		[script release];
		scrollPosition++;
		
	}

}

#pragma mark -
#pragma mark UIWebViewDelegate

/**
 When the credits web view loading is complete this method is called.  It starts a repeating
 timer which calls back to the scrollAPixel method once every 0.1 second.  
 */

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	self.scrollPosition = 0;
	scrollTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(scrollAPixel:) userInfo:nil repeats:YES];

}


@end
