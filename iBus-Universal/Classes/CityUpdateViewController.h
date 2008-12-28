//
//  CityUpdateViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "GTFSCity.h"
#import "DownloadManager.h"

@interface CityUpdateViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *updateTableView;
	GTFS_City		*updatingCity;
	NSMutableArray	*newCitiesFromServer;
	NSMutableArray	*updateCitiesFromServer;
	NSMutableArray	*otherCitiesFromServer;
	NSInteger		bytesReceived;
	BOOL			downloadingNewCity;
	BOOL			overwriteFavorites;
	NSInteger		statusOfCurrentyCity;
	NSInteger		statusOfCurrentyCityOfflineDb;
	DownloadManager *downloader;
}

/** @name Check updates without showing the view.
 *  These functions check update without showing the view, and can be done in background.
 */
//@{
- (void) checkUpdates;
- (BOOL) updateAvaiable; //This is for current city only
- (BOOL) newOfflineDatabaseAvailable;
//@}

@end
