//
//  LocationListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 10/8/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays an alphabetized list of saved locations
 
 Inherits from UIViewController
 
 The LocationListController displays an alphabetized list of locations when the user touches
 the Locations button in the LocationSettingViewController.  The list is initially populated
 with a prepared list of all observatories with altitudes above 1,000 meters.  The user can
 add their own locations to the list simply by pressing the "+" button in LocationSettingViewController.
 Because the list is quite long the list is organized alphabetically with an index down the right
 side similar to the address book.  A search box is also provided at the top of the table which can 
 be used to search for keywords in the names of the observatories.
 
 The data for the list is stored in a CoreData database.  This makes for easy storage and searching.
 
 */


@interface LocationListController : UIViewController
	<UITableViewDelegate, UITableViewDataSource,
	UISearchBarDelegate, NSFetchedResultsControllerDelegate>{

		NSManagedObjectContext *managedObjectContext;
		NSMutableArray	*locationArray;
		NSFetchedResultsController *fetchedResultsController;
		UISearchBar				*searchBar;
		UINavigationBar			*baseBar;
		UITableView				*tableView;
}

@property (nonatomic, retain) 	NSManagedObjectContext *managedObjectContext; //!< pointer to the managed object context data store
@property (nonatomic, retain) 	NSMutableArray	*locationArray; //!< an array of the locations
@property (nonatomic, retain) 	NSFetchedResultsController *fetchedResultsController; //!< pointer to the fetched results controller.
@property (nonatomic, retain) 	UISearchBar				*searchBar; //!< pointer to the search bar located in the first row of the table.
@property (nonatomic, retain) 	UITableView		*tableView; //!< pointer to embedded table view.
@property (nonatomic, retain) 	UINavigationBar			*baseBar;


@end
