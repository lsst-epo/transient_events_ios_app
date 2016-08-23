//
//  FinderImageWebViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/30/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "FinderImageWebViewController.h"
#import "Constants.h"


@implementation WebViewController
@synthesize webView;
@synthesize theURLRequest;
@synthesize activityIndicator;
@synthesize forwardButton;
@synthesize	backButton;
@synthesize toolbar;

/**
 Call initializer with nib named "FinderImageView.XIB". <br><br>
 The initializer sets the scaleContent flag to YES.  If scaling of the web content
 is not desired then the doNotScaleContentToFit must be called.
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		scaleContent = YES;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/**
 load view will load the request which has been created in the webViewForURL method
 */
- (void)viewDidLoad {//! \private
	[self.webView loadRequest:theURLRequest];
	self.webView.scalesPageToFit = scaleContent;
	UIColor *toolbarColor = kNavBarColor;
	self.toolbar.tintColor = toolbarColor;
	if (!scaleContent) {
			self.webView.alpha = kWebViewAlpha;
	}
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

/**
 Takes the URLString and creates a URLRequest which is stored in theURLRequest member variable
 */

- (void)webViewForURL:(NSString *)urlString{
	//Create URL String
	NSString *webURLstring = [[NSString alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL	*theURL = [[NSURL alloc] initWithString:webURLstring];
	self.theURLRequest = [[NSURLRequest alloc] initWithURL:theURL];
	[webURLstring release];
	[theURL release];
}

- (void)viewDidUnload {//! \private
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
/**
 Sets the scaleContent member variable to NO.
 */
- (void)doNotScaleContentToFit{
	scaleContent = NO;

}


- (void)dealloc {//! \private
	[theURLRequest release];
	webView.delegate = nil;
	[webView release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		self.webView.scalesPageToFit = YES;
	}
	if (navigationType == UIWebViewNavigationTypeBackForward) {
		//NSLog(@"WebView request and initial URL\n%@\n%@\n",request.URL.relativePath, self.theURLRequest.URL.relativePath);
		if ([request.URL.relativePath isEqualToString:self.theURLRequest.URL.relativePath]) {
			self.webView.scalesPageToFit = scaleContent;
		}
	}
	return YES;
}
/**
 starts animating the activity indicator at the start of the page loading process.
 */

- (void)webViewDidStartLoad:(UIWebView *)webView{//! \private
	[self.activityIndicator startAnimating];	
//	if ([self.webView canGoBack]) {
//		self.webView.scalesPageToFit = YES;
//	}else {
//		self.webView.scalesPageToFit = scaleContent;
//	}
	
}

/**
 Stops the animation of the activity indicator.  Sets the enabled status of the back and 
 forward buttons depending on the status of the webView canGoBack and canGoForward properties
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView{//! \private
	[self.activityIndicator stopAnimating];

	backButton.enabled = [self.webView canGoBack];
	forwardButton.enabled = [self.webView canGoForward];
}



@end
