//
//  EventListController.h
//  Transient Events
//
//  Created by Bruce E Truax on 8/7/09.
//  Copyright 2009 Diffraction Limited Design LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief Downloads and displays event table view
 
 The event list controller handles the Events tab on the tab bar.  This is the first
 page which comes up when the app is first launched.  The EventListController creates
 a POST request based on the values of the settings which are stored in user defaults.
 This POST request is sent to the server.  The server then returns a JSON formatted 
 response string which is parsed and the individual events are put into an array which 
 is then used to populate the table.  The thumbnail images which are also displayed in the
 table are queued up and downloaded in the background.  When an event is touch
 the EventListController loads a detail view controller and hands off control to the detail
 controller by pushing it onto the top of the navigation controller stack.
 
 There is a reasonable amount if intelligence in determining if the data needs to be 
 reloaded from the server.  If you go to the detail controller and then back there
 is no need to reload.  If you change a setting it is the responsibility of the setting 
 controller to send either a kRefreshNotification or a kReloadNotification to tell the
 EventList controller whether it needs to reload the data or just refresh the table view.
 
 I have tested this with very large amount of downloaded data on a first gen iPod Touch without
 encountering memory issues.  Just in case, if a memory warning is issued the image cache is 
 cleared of all images.  They then reload when needed.
 
 This object does not use CoreData for storage, just a simple array store.  This is different 
 from the BookMarkListController which uses CoreData.  Perhaps someday this can be changed.
 
 
 
 */

@interface EventListController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
	UINavigationController *navController;	 //!< Contains the navigation controller
	UITableView *tableView; //!< pointer to the table view
	NSArray *transientDataArray; //!< The array of transient data after parsing by the JSON parser
	NSOperationQueue *operationQueue;
	UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
	BOOL returningFromDetailView;
	NSMutableDictionary *cachedImages; //!< store for cached images url is key for image data
	NSMutableData *resultsData; //!< store fore results data after parsing
	NSURLConnection *urlConnection;
	UIImage *loadingImage; //!< pointer to "Loading…" image
	UIImage *alertImage;	//!< pointer to ALERT image
	NSIndexPath	*currentSelection; //!< state variable for selected row
	NSUserDefaults *userDefaults;
	int		resumptionToken; //!< token telling the server where to resume its search for the next batch of results
	BOOL	reloadNeeded;
	BOOL	refreshNeeded;
	BOOL	loadingMoreData;
}

@property (nonatomic, retain)	UINavigationController *navController;
@property (nonatomic, retain) 	UITableView *tableView;
@property (nonatomic, retain) 	NSArray *transientDataArray;
@property (nonatomic, retain) 	NSMutableDictionary *cachedImages;
@property (nonatomic, retain) 	NSMutableData *resultsData;
@property (nonatomic, retain) 	NSURLConnection *urlConnection;
@property (nonatomic, retain) 	UIImage *loadingImage;
@property (nonatomic, retain) 	UIImage *alertImage;
@property (nonatomic, retain) 	NSIndexPath	*currentSelection;
@property (assign)				int resumptionToken;




- (void)beginLoadingTransientData; //!< starts loading transient data synchronously
- (void)showLoadingIndicators; //!< shows the loading indicator
- (void)hideLoadingIndicators; //!< hides the loading indicator
- (UIImage *)cachedImageForURL:(NSURL *)url; //!< gets the image with the specified URL downloads if necessary
- (void)didFinishLoadingImageWithResult:(NSDictionary *)result; //!< callback function for ImageLoadingOperation
- (void)beginLoadingTransientDataAsync; //!< starts background loading of Transient data from server
- (void)removeNonVisibleObjects; //!< Removes objects which are below minimum elevation
- (IBAction)displayHelp; //!< displays help page
- (IBAction)reloadEvents; //!< forces reload of all events
- (void)setNeedsReload; //!< sets flag to to tell EventListController to reload all data
- (void)setNeedsRefresh; //!< sets flag to tell EventListController to redisplay table
- (void)alertOccurred; //!< handles an immediate redisplay if an alert occurs
- (void)setFooterForTableView; //!< sets the correct size footer for the event list table. DEPRECATED
@end
