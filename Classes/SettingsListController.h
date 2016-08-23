//
//  SettingsListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Displays the settings page
 
 Inherits from UIViewController
 
 The SettingsListController displays the settings page.  It is instatiated by the
 AppDelegate.  
 
 Most of the individual settings are handled by their own controllers.
 
 */

@interface SettingsListController : UIViewController
	<UITableViewDataSource, UITableViewDelegate>{
		
		UINavigationController *navController;
		UITableView *tableView;	
		NSArray			*titles;
		NSArray			*groupTitles;
		NSUserDefaults	*userDefaults;
		NSArray			*RAFormatArray;

}

@property (nonatomic, retain)	UINavigationController *navController;
@property (nonatomic, retain)	NSArray			*groupTitles; //!< Array containing the titles of the groups used in the table
@property (nonatomic, retain)	NSArray			*titles; //!< Array containing the names of each setting item
@property (nonatomic, retain)	NSUserDefaults	*userDefaults; //!< Pointer to user defaults
@property(nonatomic, retain)	NSArray *RAFormatArray; //!< Array containing a list of the RA formatting options
@property (nonatomic, retain) 	UITableView		*tableView;

- (void)visibleObjectsOnDidChangeState:(id)sender;  //!< \private Callback when visible objects on/off switch changes state
- (void)eventThumbnailsOnDidChangeState:(id)sender; //!< \private Callback when Thumbnails on/off switch changes state
- (void)alertsOnDidChangeState:(id)sender; //!< \private Callback when alerts on/off switch changes state.
- (void)displayHelp; //!< \private Displays help for this page
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; //!< \private Sets up the UITableView rows
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; //!< \private Called when a row is touched UITableViewDelegate

@end
