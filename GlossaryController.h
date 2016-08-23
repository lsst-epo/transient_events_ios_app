//
//  GlossaryController.h
//  Transient Events
//
//  Created by Nathan Fitzgibbon on 12/7/11.
//  Copyright (c) 2011 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlossaryController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *listOfItems;
}

    

@property (nonatomic, retain) UINavigationController	*navController;



@end
