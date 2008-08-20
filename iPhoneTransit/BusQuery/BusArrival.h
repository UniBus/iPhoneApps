//
//  BusArrival.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface BusArrival : NSObject {
	NSInteger stopId;
	NSDate *arrivalTime;
	NSString *busSign;
	BOOL departed;
}

@property BOOL departed;
@property NSInteger stopId;

- (NSComparisonResult) compare: (BusArrival *)avl;

- (NSDate *) arrivalTime;
- (void) setArrivalTime: (NSDate *) arrivalAt;
- (void) setArrivalTimeWithInterval: (NSTimeInterval) arrivalAt;

- (NSString *) busSign;
- (void) setBusSign: (NSString *) sign;


@end
