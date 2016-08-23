//
//  ImageLoadingOperation.m
//  MyTableView
//
//  Originally Version Created by Evan Doll on 10/27/08
//	as part of CS193P.
//  Used as a template to create the image loading function
//	Needed for TransientEvents
//  Copyright 2008 Diffraction Limited Design LLC. All rights reserved.
//


#import "ImageLoadingOperation.h"
#import "Constants.h"

NSString *const ImageResultKey = @"image";
NSString *const URLResultKey = @"url";

@implementation ImageLoadingOperation
@synthesize smallImages;

- (id)initWithImageURL:(NSURL *)theImageURL target:(id)theTarget action:(SEL)theAction
{
    self = [super init];
    if (self) {
        imageURL = [theImageURL retain];
        target = [theTarget retain];
        action = theAction;
		cancelRequested = NO;
		mainThread = [NSThread mainThread];
		smallImages = NO;
    }
    return self;
}

- (void)cancel{
	//If cancel is requested we will allow the current image loading operation to complete (since we cannot stop it)
	//But we will not allow the message to be sent to the main thread because it will no longer be listening.
	cancelRequested = YES;
}

- (void)dealloc
{//! \private
    [imageURL release];
    [result release];
    [target release];

	[super dealloc];
}

- (void)main
{
	// Synchronously load the data from the specified URL.	
	NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
	UIImage *image = nil;
	UIImage *largeImage = nil;	
	NSData *data = nil;
	//this next section of code was written to try to eliminate a bug which appears
	//to be in the simulator SDK image resizing algorithm
	if (NO && [imageURL isFileURL]) { //[imageURL isFileURL]
//		largeImage = [UIImage imageWithContentsOfFile:[imageURL path]];
//		CGSize newSize ;
//		newSize.height = kTableViewRowHeight-5;
//		newSize.width = kTableViewRowHeight-5;
//		UIGraphicsBeginImageContext( newSize );
//		//			NSLog(@"largeImage Retain Count = %i",[largeImage retainCount]);
//		[largeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//		image = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//		NSLog(@"largeImage = %@, Image = %@",largeImage, image);
//		[image retain];
		
	}else {
		data = [[NSData alloc] initWithContentsOfURL:imageURL];
		if (data && [data length] >0 ) {
			if (smallImages) {
				//we want small images so resize
				largeImage = [[[UIImage alloc] initWithData:data]autorelease];
				if (largeImage == nil){
					//we got data but it was not image data so stick in missing image
					largeImage = [UIImage imageNamed:@"MissingImage.png"];
				}
				CGSize newSize ;
				newSize.height = kTableViewRowHeight-5;
				newSize.width = kTableViewRowHeight-5;
				CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB(); 
				CGContextRef context = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
															 8,
															 4 * newSize.width,
															 colorSpaceRef,
															 kCGImageAlphaPremultipliedLast);
				CGColorSpaceRelease(colorSpaceRef);
				CGRect rect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
				CGContextClearRect(context, rect);
				
				// Do your drawing and image manipulation..
//				CFDataRef imgData = (CFDataRef)data;
//				CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData (imgData);
//				CGImageRef cgTempImage = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
				CGImageRef cgTempImage = largeImage.CGImage;
				CGContextDrawImage(context, rect, cgTempImage);
				
				CGImageRef cgImage = CGBitmapContextCreateImage(context);
				image = [UIImage imageWithCGImage:cgImage];
//				CGImageRelease(cgTempImage);
				CGImageRelease(cgImage);
				CGContextRelease(context);
//				UIGraphicsBeginImageContext( newSize );
//				[largeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];  //crash here when URL is of type file:// !!!!!
//				image = UIGraphicsGetImageFromCurrentImageContext();
//				UIGraphicsEndImageContext();
			}else {
				image = [[[UIImage alloc] initWithData:data]autorelease];
				if (image == nil){
					//we got data but it was not image data so stick in missing image
					image = [UIImage imageNamed:@"MissingImage.png"];
				}
			}
			
		}else{
			NSLog(@"Link did not work so stick in a placeholder");
			//The link did not work so load a placeholder
			if (smallImages) {
				largeImage = [UIImage imageNamed:@"MissingImage.png"];
				
				CGSize newSize ;
				newSize.height = kTableViewRowHeight-5;
				newSize.width = kTableViewRowHeight-5;
				UIGraphicsBeginImageContext( newSize );
				[largeImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
				image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				//			[image retain];
				
			}else {
				image = [UIImage imageNamed:@"MissingImage.png"];
				
			}
		}


		
	}
	// Package it up to send back to our target.

	result = [[NSDictionary alloc] initWithObjectsAndKeys:image, ImageResultKey, imageURL, URLResultKey, nil];
	
			
	if (!cancelRequested){
		[target performSelectorOnMainThread:action withObject:result waitUntilDone:NO];
	}else{
//		NSLog(@"ImageLoadingOperation thread aborted because main thread has changed");
	}
	[data release];
	[myPool release];

}

@end
