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

@interface TransitApp : UIApplication {
	ArrivalQuery *arrivalQuery;
	StopQuery    *stopQuery;
	int cityId;
}

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm;
- (NSArray *) arrivalsAtStops: (NSArray*) stops;

@end
