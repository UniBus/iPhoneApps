//
//  OfflineQuery.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 29/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OfflineQuery : NSObject {
	BOOL         available;
}

@property BOOL available;

- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop onDay:(NSString *)day;
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop;
- (NSArray *) queryForStops: (NSArray *) stops;

@end
