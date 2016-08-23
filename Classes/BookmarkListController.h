//
//  BookmarkListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
@brief Displays the list of bookmarked objects

 The BookmarkListController handles the Bookmarks tab on the tab bar.  The BookmarkListController
 pulls the Transient data objects from the CoreData store and displays them in the table view.  
 The thumbnail images which are also displayed in the table are stored in the Transient data object.
 
 When an event is touched the BookmarkListController loads a BookmarkDetailController
 by pushing it onto the top of the navigation controller stack.

This is different from the EventListController because it uses CoreData.  
Perhaps someday EventListController and this controller can be merged.  It would make 
 maintenance simpler.
 
 */

@interface BookmarkListController : UIViewController 
			<NSFetchedResultsControllerDelegate,UITableViewDataSource, UITableViewDelegate> {
	UINavigationController	*navController;
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	UITableView *tableView; //!< pointer to the table view
	
	NSUserDefaults *userDefaults;

}

@property (nonatomic, retain) UINavigationController	*navController;
@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) 	NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) 	UITableView *tableView ;

- (void)setFooterForTableView; //!< Sets the footer for the table view
- (void)displayHelp; //!< Displays the help page


@end
