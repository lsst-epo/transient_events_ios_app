//
//  FinderImageViewController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/23/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays a finder image - NOT CURRENTLY USED
 
 Inherits from UIViewController
 
 FinderImageViewController displays a finder image and allows zooming and panning.  The
 image is displayed in a scroll view and the subject star is highlighted by drawing a box
 around it.  The image is allowed to zoom to 3x pixel resolution.
 */


@interface FinderImageViewController : UIViewController <UIScrollViewDelegate>{
	IBOutlet UIImageView	*imageView;
	UIImage		*finderImage;
	IBOutlet UIScrollView	*scrollView;
}

@property (nonatomic, retain) 	UIImageView	*imageView;//!< The image view for the finder image
@property (nonatomic, retain) 	UIImage	*finderImage; //!< The finder image which the calling software must set after initialization and before displaying this view
@property (nonatomic, retain) 	UIScrollView *scrollView; //!< The scroll view which contains the image




@end
