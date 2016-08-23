//
//  ImageLoadingOperation.h
//  MyTableView
//
//  Created by Evan Doll on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//




#import <UIKit/UIKit.h>

extern NSString *const ImageResultKey;
extern NSString *const URLResultKey;
/**
 @brief Loads images from server
 
 This object is used to load the images.  It is meant to be call as an NSOperation.
 The object is instatiated and passed the image URL as well as the object and method
 to call when the operation is complete.  
 
 It is typically called as follows:
 ImageLoadingOperation *operation = [[ImageLoadingOperation alloc] initWithImageURL:url target:self action:@selector(didFinishLoadingImageWithResult:)];
 operation.smallImages = YES;
 [operationQueue addOperation:operation];
 [operation release];
 
 By setting smallImages to YES the image loading operation will resize the images to kTableViewRowHeight - 5 pixels.
 This is used when loading images for display as thumbnails for each row.  By resizing the images
 in this method it is not necessary to resize them each time a cell is created.  Makes for much quicker scrolling.
 
 When cancelling the operation queue it is recommended that you also call the cancel method.  Typically 
 the operation queue is canceled when the calling object ceases to exist in the dealloc method.  If 
 you do not also call the cancel method an in-process operation may not get terminated in which case
 it will attempt to call back to the instantiating object upon completion.  If this object has been 
 deallocated the attempted call will crash the app.  The cancel method sets a flag which prevents the callback method 
 from being executed.
 
 */
@interface ImageLoadingOperation : NSOperation {
    NSURL *imageURL; /*!< url of image to load */
    id target;		/**< object for callback */
    SEL action;		/**< method to call on callback */
	NSDictionary *result; /**< dictionary used to return results on callback */
	BOOL cancelRequested; /**< flag to set to request the operation to cancel */
	NSThread *mainThread; /**< internal use only */
	BOOL smallImages;	/**< set this flag if you want small images to use for table view */
}

@property (assign) BOOL smallImages;
/**
 Initializer Pass in url of image and object and method for callback
 
 The selector must recieve type NSDictionary
 
 */
- (id)initWithImageURL:(NSURL *)imageURL target:(id)target action:(SEL)action;

@end
