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

extern NSString * const UserSavedRecentStopsAndBuses;
extern NSString * const UserSavedFavoriteStopsAndBuses;
extern NSString * const UserSavedSearchRange;
extern NSString * const UserSavedSearchResultsNum;
extern NSString * const UserApplicationTitle;

@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	NSString     *dataFile;
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

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) arrivalsAtStops: (NSArray*) stops;
- (void) arrivalsAtStopsAsync: (id)stopView;
- (void) scheduleAtStopsAsync: (id)stopView;

- (NSString *) currentDatabase;
- (NSString *) currentWebServicePrefix;

@end
