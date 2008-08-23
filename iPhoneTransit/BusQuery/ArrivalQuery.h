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
}

- (NSArray *) queryForStops: (NSArray*) stops;
- (NSArray *) queryByURL: (NSURL *) url;

@end
