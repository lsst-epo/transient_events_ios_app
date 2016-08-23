//
//  AboutTransientEventsView.h
//  Transient Events
//
//  Created by Bruce E Truax on 10/6/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays the About view
 
 Inherits from UIViewController
 
 The AboutTransientEventsView displays the about view page.  The page itself consists
 of some pretty graphics, a scrolling web view where the about text appears and a
 couple of UILabel objects used to display the build date, version and build number.
 
 The credits web view will slowly scroll though the entire page unless the user manually
 scrolls the page.  If this happens the auto scrolling is canceled.

 NOTE:  The build date and time are derived from the compiler directives __DATE__ and 
 __TIME__.  These are updated when this file is built.  Normally, if the file does not change
 these value do not get updated.  In order to make sure they are updated the build script
 "touches" the implementation file at the beginning of the build process.  This assures that
 the impelementation file is always recompiled for each build.
 */



@interface AboutTransientEventsView : UIViewController <UIWebViewDelegate> {
	IBOutlet	UILabel		*versionNumber;
	IBOutlet	UILabel		*buildDate;
	IBOutlet	UIWebView	*creditsWebView;
	IBOutlet	UIView		*tintView;
	NSTimer		*scrollTimer;
	int			scrollPosition;
	

}

@property (nonatomic, retain) 	UILabel		*versionNumber; //!< The curren version number including build number
@property (nonatomic, retain) 	UILabel		*buildDate; //!< The build date which comes from compiler directives.  This file must be "touched" for these to update.
@property (nonatomic, retain) 	UIWebView	*creditsWebView; //!< A scrolling web view used to display the credits
@property (nonatomic, retain)	NSTimer		*scrollTimer;	//!< timer for scrolling web view
@property (assign)				int			scrollPosition;	//!< the position of the webview scroll
@property (nonatomic, retain) 	UIView		*tintView;//!< view to tint background

- (void)viewDidLoad ; //!< This is where all of the work is done, called when the view is loaded
- (void)scrollAPixel:(NSTimer *)aTimer; //!< Called by repeating timer and scrolls the web view by one pixel
- (void)webViewDidFinishLoad:(UIWebView *)webView; //!< UIWebView Delegate method, called when view is finished loading

- (IBAction)touchedLSST:(id)sender; //!< If the user touches LSST they are sent to the LSST web site

@end
