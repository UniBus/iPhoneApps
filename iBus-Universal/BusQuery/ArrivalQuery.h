//
//  ArrivalQuery.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>

@interface ArrivalQuery : NSObject {
	NSMutableArray *arrivalsForStops;
	NSString *webServicePrefix;
}

@property (retain) NSString * webServicePrefix;

- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop onDay:(NSString *)day;
- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop;
- (NSArray *) queryForStops: (NSArray *) stops;
- (NSArray *) queryByURL: (NSURL *) url;

@end
