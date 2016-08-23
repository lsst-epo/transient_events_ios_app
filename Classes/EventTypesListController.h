//
//  EventTypesListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 9/4/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Displays the list of event types and allows the user to check which event types to display.
 
 Inherits from UIViewController
 
 The EventTypesListController displays a list of possible event types which are read from EventTypeDictionary.plist.
 The event types are displayed in a table view and initially all are checked.  The user can then touch each 
 row to select/deselect a particular event type.  Each time this is done the eventDitionary is updated.
 
 The eventDictionary is NSMutableDictionary who's keys are the event types.  Each key refers to a boolean value which
 is set to YES if the event is to be displayed and NO if it is not to be displayed.  All event types which are set
 to yes are shown in the table view with checkmarks next to them.
 
 NOTE: It is not allowed to turn off all events.  If this is done the user will be warned upon exiting the view
 and the state of the event dictionary upon entering the view will be restored.
 */



@interface EventTypesListController : UIViewController 
<UITableViewDataSource, UITableViewDelegate>{
	NSArray			*list; 
	NSUserDefaults	*userDefaults;
	UITableView		*tableView;
	
	NSMutableDictionary	*eventDictionary;
	NSDictionary *backupEventDictionary;
	
}

@property(nonatomic, retain)	NSArray *list;//!< list of eventTypes used for the tableView display
@property(nonatomic, retain)	NSUserDefaults *userDefaults; //!< pointer to userDefaults
@property(nonatomic, retain)	NSMutableDictionary	*eventDictionary; //!< eventDictionary containing the state of each event type
@property(nonatomic, retain)	NSDictionary	*backupEventDictionary; //!< Dictionary containing a backup of the starting state
@property(nonatomic, retain)	UITableView		*tableView; //!< pointer to the embedded table view
@end
