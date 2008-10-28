//
//  StopQuery-CSV.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StopQuery.h"
#import <sqlite3.h>

@interface StopQuery_CSV : StopQuery {
	NSMutableArray *rawStops;	
	sqlite3 *database;

	NSInteger columnStopId;
	NSInteger columnStopName;
	NSInteger columnStopLat;
	NSInteger columnStopLon;
	NSInteger columnStopPos;
	NSInteger columnStopDir;
	NSInteger columnStopDesc;
}

- (BOOL) openStopFile: (NSString *)stopFile;
- (BOOL) saveStopFile: (NSString *)stopFile;
- (BOOL) saveToSQLiteDatabase: (NSString *)dbName;

@end
