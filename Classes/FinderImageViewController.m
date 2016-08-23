//
//  FinderImageViewController.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/23/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "FinderImageViewController.h"


#define kBoxSize 0.05

@implementation FinderImageViewController
@synthesize imageView;
@synthesize finderImage;
@synthesize scrollView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		

    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	scrollView.contentSize = CGSizeMake((self.finderImage.size.width),
										self.finderImage.size.height);
//	imageView = [[FinderImageView alloc] initWithImage:self.finderImage];
		
	UIGraphicsBeginImageContext( scrollView.contentSize);
	CGFloat xMin, xMax, yMin, yMax;
	xMin = self.finderImage.size.width/2.0 ;
	xMin -= self.finderImage.size.width *kBoxSize/(2.0);
	xMax = xMin + self.finderImage.size.width*kBoxSize;
	
	yMin = self.finderImage.size.height/2.0 - self.finderImage.size.width*kBoxSize/(2.0);
	yMax = yMin + self.finderImage.size.width*kBoxSize;
	
	//Now draw a box around the center of the image where the target is located
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.finderImage drawInRect:CGRectMake(0, 0, self.finderImage.size.width, self.finderImage.size.height)];
	CGContextSetAllowsAntialiasing(context, false);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
	CGContextBeginPath(context);
	//first we will compute the extents of the box
	CGContextMoveToPoint(context, xMin, yMin);
	CGContextAddLineToPoint(context, xMin, yMax);
	CGContextAddLineToPoint(context, xMax, yMax);	
	CGContextAddLineToPoint(context, xMax, yMin);	
	CGContextAddLineToPoint(context, xMin, yMin);   
	CGContextStrokePath(context);
	imageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
	UIGraphicsEndImageContext();
	CGRect frame = scrollView.frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	frame.size.width = scrollView.contentSize.width;
	frame.size.height = scrollView.contentSize.height;
	imageView.frame = frame;
	imageView.userInteractionEnabled = YES;
	imageView.multipleTouchEnabled = YES;

	[scrollView addSubview:imageView];
	
	scrollView.clipsToBounds = YES;
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	//Now lets compute the max and min zoom
	//Min zoom will be when the entire image fits in the view
	//Max zoom will be 3x pixel resolution of the original image
	
	float minZoom = MIN(scrollView.frame.size.width/finderImage.size.width, scrollView.frame.size.height/finderImage.size.height);
	scrollView.minimumZoomScale = minZoom;
	float maxZoom = MAX(scrollView.frame.size.width/finderImage.size.width, scrollView.frame.size.height/finderImage.size.height);
	scrollView.maximumZoomScale = 3;
	
	//Now set to minimum zoom so we can see the entire image
	[scrollView setZoomScale:maxZoom animated:NO];
	float xOffset = (self.scrollView.contentSize.width  - self.scrollView.frame.size.width)/2.0;
	float yOffset = (self.scrollView.contentSize.height  - self.scrollView.frame.size.height)/2.0;
	[self.scrollView setContentOffset:CGPointMake(xOffset,yOffset) animated:NO];

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event{
		if ([[touches anyObject] tapCount] == 2){
			self.scrollView.zoomScale = MIN(self.scrollView.maximumZoomScale, 2.0 * self.scrollView.zoomScale);
		}
}


- (void)dealloc {
	[imageView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return imageView;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
//	NSLog(@"Ending Zoom Scale = %f",scale);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//	NSLog(@"Content offset = %f, %f",scrollView.contentOffset.x, scrollView.contentOffset.y);
}


@end
