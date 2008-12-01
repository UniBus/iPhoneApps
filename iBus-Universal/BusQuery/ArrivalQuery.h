//
//  ArrivalQuery.h
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "PhpXmlQuery.h"

@interface ArrivalQuery : PhpXmlQuery {
	NSMutableArray *arrivalsForStops;
}

- (BOOL) available;
- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop onDay:(NSString *)day;
- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop;
- (NSArray *) queryForStops: (NSArray *) stops;

@end
