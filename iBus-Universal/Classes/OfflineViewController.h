//
//  CityUpdateViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "DownloadManager.h"

void updateOfflineDbInfoInGTFS(NSString *cityId, int downloaded, NSString *downloadTime);
BOOL offlineDbDownloaded(NSString *cityId);
NSString *offlineDbDownloadTime(NSString *cityId);

@interface OfflineViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	DownloadManager	*downloader;
	UITableView		*offlineTableView;
}

- (IBAction) automaticSwitchTap:(id)sender;
- (IBAction) alwaysOfflineTap:(id)sender;

@end
