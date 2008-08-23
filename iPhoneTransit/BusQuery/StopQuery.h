//
//  StopQuery.h
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "BusStop.h"

@interface StopQuery : NSObject {
	NSMutableArray *rawStops;	
	double distanceThreshold;
	NSMutableArray *sortedStops;
	double minLongtitude;
	double maxLongtitude;
	double maxLatitude;
	double minLatitude;
	int numberOfLonGrid;
	int numberOfLatGrid;
}

@property double distanceThreshold;

//Create an object with the stop file
+ (id) initWithFile:(NSString *) stopFile;
- (BOOL) openStopFile: (NSString *)stopFile;

//Some propertoes
- (NSMutableArray *) stops;
- (void) setStops:(NSMutableArray *)newStops;
- (NSInteger) numberOfStops;
- (BusStop *) stopAtIndex: (NSInteger) index;

//Query the closest stops with given pos (with longtitude and latitude)
- (NSArray *) queryStopWithPosition:(CGPoint) pos within:(double)distInKm;
- (NSArray *) queryStopWithPosition:(CGPoint) pos;

- (BusStop *) stopOfId: (NSInteger) id;

@end
