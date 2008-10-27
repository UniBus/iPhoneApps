//
//  CityUpdateViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTFSCity.h"

@interface CityUpdateViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *updateTableView;
	GTFS_City	   *updatingCity;
	NSMutableArray *newCitiesFromServer;
	NSMutableArray *updateCitiesFromServer;
	NSMutableArray *otherCitiesFromServer;
	NSURLResponse  *downloadResponse;
	//UIProgressView *downloadProgress;
	NSURLDownload  *theDownload;
	UIActionSheet  *downloadActionSheet;
	NSInteger		bytesReceived;
	BOOL			downloadingNewCity;
	BOOL			overwriteFavorites;
	NSInteger		downloadState;
	BOOL			needUpdateForCurrentyCity;
}

@end
