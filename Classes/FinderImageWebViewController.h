//
//  FinderImageWebViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/30/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays a web view primarily for the finder image web page.  
 
 Initially used just for displaying the finder page.  It is now also used for displaying the 
 help pages because they had similar requirements.  This web view does not allow entering a URL
 by hand.  It does have forward and back buttons.  This allows the user to navigate to links
 in a web page but it does not allow it to be used as a general purpose browser.
 
 To display a finder chart instantiate and 
 call as follows:
 <CODE>
 <br>
	 WebViewController *finderImageView = [[WebViewController alloc] initWithNibName:@"FinderImageWebView" bundle:nil];<br>
	 finderImageView.title = @"Finder Chart";<br>
	[finderImageView webViewForURL:[[self.eventDetails objectForKey:kFinderChartPageURLKey]objectAtIndex:0]];<br>
	 finderImageView.hidesBottomBarWhenPushed = YES;<br>
	 [self.navigationController pushViewController:finderImageView animated:YES];<br><br>
</CODE>
 To use this to display a help view use the following method to call the object:
 <CODE>
 <br><br>
	 WebViewController *helpView = [[WebViewController alloc] initWithNibName:@"FinderImageWebView" bundle:nil];<br>
	 //Set the doNotScaleToFit flag so the page is displayed at full scale.  <br>
	 [helpView doNotScaleContentToFit];<br>
	 helpView.title = @"Help";<br>
	 //Get the help content and pass it to the help view<br>
	 [helpView webViewForURL:[[NSBundle mainBundle] pathForResource:kEventListHelpFile ofType:@"html"]];<br>
	 helpView.hidesBottomBarWhenPushed = YES;<br>
	 [self.navigationController pushViewController:helpView animated:YES];<br>
 <br>
 </CODE>
 The difference between the to instantiations is that for the web view you do not call doNotScaleContentToFit and and you pass an
 external URL which points to a page on the web.  For the help view you call doNotScaleContentToFit (because we already formatted the
 page to the proper size) and you pass a URL which points to a file in the bundle.
 
 NOTE:  The file names FinderImageWebViewController.* is a holdover from when the object was first written.  This should be changed
 once we abandon the initial branch for he push branch.
 
 */


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet	UIWebView	*webView;
	NSURLRequest *theURLRequest;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UIBarButtonItem	*forwardButton;
	IBOutlet UIBarButtonItem	*backButton;
	IBOutlet UIToolbar			*toolbar;
	BOOL scaleContent;  //!< Flag which tells the web view whether to scale content

}

@property (nonatomic, retain) 	UIWebView	*webView; //!< Pointer to the web view container in the XIB
@property(nonatomic, retain)	NSURLRequest *theURLRequest;
@property(nonatomic, retain)    UIActivityIndicatorView *activityIndicator; //!< pointer to the activity indicator in the XIB
@property(nonatomic, retain)    UIBarButtonItem	*forwardButton; //!< pointer to the forward button in the XIB
@property(nonatomic, retain)    UIBarButtonItem	*backButton; //!< pointer to the back button in the XIB
@property (nonatomic, retain) 	UIToolbar		*toolbar; //!< point to the toolbar in the XIB

- (void)webViewForURL:(NSString *)urlString; //!< Sets the URL for the web view
- (void)doNotScaleContentToFit; //!< tells the web view not to scale the content.  Must be called before webViewForURL
@end
