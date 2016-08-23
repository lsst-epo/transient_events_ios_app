//
//  FinderImageView.m
//  Transient Events
//
//  Created by Bruce E Truax on 9/28/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import "FinderImageView.h"

#define kBoxSize  0.05

/**
 @brief Displays a simple image with a box at the center.  DEPRECATED _ NOT USED
 */


@implementation FinderImageView

@synthesize finderImage;

- (id)initWithImage:(UIImage *)image{
	if (self = [super initWithImage:image]) {
        // Custom initialization
		[self drawRect:self.frame];
		
    }
    return self;
	
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	float xMin, xMax, yMin, yMax;
	xMin = self.image.size.width/2 - self.image.size.width/(2*kBoxSize);
	xMax = xMin + self.image.size.width/kBoxSize;
	
	yMin = self.image.size.height/2 - self.frame.size.width/(2*kBoxSize);
	yMax = yMin + self.image.size.width/kBoxSize;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, xMin, yMin);
	CGContextAddLineToPoint(context, xMin, yMax);
	CGContextAddLineToPoint(context, xMax, yMax);	
	CGContextAddLineToPoint(context, xMax, yMin);	
	CGContextAddLineToPoint(context, xMin, yMin);   
	CGContextStrokePath(context);
	
}


- (void)dealloc {
	[finderImage release];
    [super dealloc];
}


@end
