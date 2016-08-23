//
//  ObjectInfoPageController.h
//  Transient Events
//
//  Created by Nathan Fitzgibbon on 12/2/11.
//  Copyright (c) 2011 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectInfoPageController : UIViewController


@property (nonatomic, retain) NSString *eventDetails;
@property (nonatomic, retain) IBOutlet UITextView *infoView;

@end
