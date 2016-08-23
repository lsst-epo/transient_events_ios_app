//
//  RAFormatListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Displays the table with the RA/Dec formatting selections
 
 Inherits from UIViewController
 
 The RAFormat list controller displays a small table view which lists the 
 RA/DEC formatting options (of which there are currently 2).  These options are
 listed in RAFormat.plist file.
 
 The user can select one of these options by touching it.  When touched a checkmark
 appears next to the selection.
 
 The selections work like radio buttons in that their selection is mutually exclusive.
 */



@interface RAFormatListController : UIViewController 
<UITableViewDataSource, UITableViewDelegate>{
	NSArray			*list;
	NSUserDefaults	*userDefaults;
	UITableView *tableView;	

}

@property(nonatomic, retain)	NSArray *list; //!< list of selection options
@property(nonatomic, retain)	NSUserDefaults *userDefaults; //!< pointer to user defaults
@property (nonatomic, retain) 	UITableView		*tableView;





@end
