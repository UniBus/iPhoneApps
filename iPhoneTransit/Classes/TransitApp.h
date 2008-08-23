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

@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	NSString     *dataFile;
	BOOL         queryAvailable;
	int          cityId;
	NSOperationQueue  *opQueue;
}

@property BOOL queryAvailable;
- (BusStop *) stopOfId:(int) stopId;
- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) arrivalsAtStops: (NSArray*) stops;
- (int) numberOfStops;

@end
