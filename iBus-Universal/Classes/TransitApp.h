//
//  TransitApp.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrivalQuery.h"
#import "StopQuery.h"

extern NSString * const UserSavedSearchRange;
extern NSString * const UserSavedSearchResultsNum;
extern NSString * const UserApplicationTitle;
extern NSString * const UserSavedSelectedPage;

extern NSString * const UserCurrentCityId;
extern NSString * const UserCurrentCity;
extern NSString * const USerCurrentDatabase;
extern NSString * const UserCurrentWebPrefix;

@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	NSString     *dataFile;
	
	NSString	 *currentCity;
	NSString	 *currentCityId;
	NSString	 *currentDatabase;
	NSString	 *currentWebPrefix;
	
	BOOL         stopQueryAvailable;
	BOOL         arrivalQueryAvailable;
	int          cityId;
	NSOperationQueue  *opQueue;
}

@property BOOL arrivalQueryAvailable;
@property BOOL stopQueryAvailable;

- (BusStop *) getRandomStop;
- (BusStop *) stopOfId:(NSString *) stopId;
- (NSArray *) queryStopWithPosition:(CGPoint) pos;
- (NSArray *) queryStopWithName:(NSString *) stopName;
- (NSArray *) queryStopWithNames:(NSArray *) stopNames;
- (NSArray *) queryStopWithIds:(NSArray *) stopIds;

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) arrivalsAtStops: (NSArray*) stops;
- (void) arrivalsAtStopsAsync: (id)stopView;
- (void) scheduleAtStopsAsync: (id)stopView;

- (void) setCurrentCity:(NSString *)city cityId:(NSString *)cid database:(NSString *)db webPrefix:(NSString *)prefix;
- (NSString *) currentCity;
- (NSString *) currentCityId;
- (NSString *) currentDatabase;
- (NSString *) currentWebServicePrefix;
- (NSString *) currentDatabaseWithFullPath;
- (NSString *) localDatabaseDir;
- (NSString *) gtfsInfoDatabase;
- (void) citySelected:(id)sender;
- (void) onlineUpdateRequested:(id)sender;

@end
