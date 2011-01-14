//
//  GTFSCity.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 25/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

int totalNumberOfCitiesInGTFS();
BOOL offlineDbUpdateAvailable(NSString *cityId);
BOOL cityDbUpdateAvailable(NSString *cityId);
void updateOfflineDbInfoInGTFS(NSString *cityId, int downloaded, NSString *downloadTime);
BOOL offlineDbDownloaded(NSString *cityId);
NSString *offlineDbDownloadTime(NSString *cityId);

@interface GTFS_City : NSObject
{
	NSString *cid;
	NSString *cname;
	NSString *cstate;
	NSString *country;
	NSString *website;
	NSString *dbname;
	NSString *lastupdate;
	NSString *lastupdatelocal;
	NSString *oldbtime;
	NSString *oldbtimelocal;
	NSInteger local;
	NSInteger oldbdownloaded;
}

@property (retain) NSString *cid;
@property (retain) NSString *cname;
@property (retain) NSString *cstate;
@property (retain) NSString *country;
@property (retain) NSString *website;
@property (retain) NSString *dbname;
@property (retain) NSString *lastupdate;
@property (retain) NSString *lastupdatelocal;
@property (retain) NSString *oldbtime;
@property (retain) NSString *oldbtimelocal;
@property NSInteger	        local;
@property NSInteger         oldbdownloaded;

- (BOOL) isSameCity: (GTFS_City *)city;
- (BOOL) isEqualTo: (GTFS_City *)city;

@end

