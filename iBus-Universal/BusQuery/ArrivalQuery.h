//
//  ArrivalQuery.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "PhpXmlQuery.h"

@interface ArrivalQuery : PhpXmlQuery {
	NSMutableArray *arrivalsForStops;
}

/** @name Search/query for arrivals
 *
 *  These functions query bus arrival schedules.
 */
//@{
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop onDay:(NSString *)day;
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop;
- (NSArray *) queryForStops: (NSArray *) stops;
//@}

@end
