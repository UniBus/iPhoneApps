//
//  BusArrival.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>
#import "BusArrival.h"

@implementation BusArrival

@synthesize departed, stopId, flag;

- (void) dealloc
{
	[arrivalTime release];
	[busSign release];
	[super dealloc];
}

- (NSComparisonResult) compare: (BusArrival *)avl
{
	if (stopId < avl.stopId)
		return NSOrderedAscending;
	else if (stopId > avl.stopId)
		return NSOrderedDescending;
	else if ([busSign isEqualToString:[avl busSign]])
		return [arrivalTime compare:[avl arrivalTime]];
	else
		return [busSign compare:[avl busSign]];
}

- (NSDate *) arrivalTime
{
	return arrivalTime;
}
	
- (void) setArrivalTime: (NSDate *) arrivalAt
{
	[arrivalAt release];
	arrivalTime = [arrivalAt copy];
}

- (void) setArrivalTimeWithInterval: (NSTimeInterval) arrivalAt
{
	[arrivalTime release];
	arrivalTime = [[NSDate dateWithTimeIntervalSince1970: arrivalAt] retain];
}

- (NSString *) busSign
{
	return busSign;
}

- (void) setBusSign: (NSString *) sign
{
	[busSign release];
	busSign = [sign copy];
}
			
@end
