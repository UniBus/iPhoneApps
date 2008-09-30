//
//  BusArrival.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <UIKit/UIKit.h>
#import "BusArrival.h"

#define  Arrival_Key_StopId     @"StopId"
#define  Arrival_Key_BusSign    @"BusSign"


@implementation BusArrival

@synthesize departed, flag;

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

- (NSString*) arrivalTime
{
	return arrivalTime;
}
	
- (void) setArrivalTime: (NSString *) arrivalAt
{
	[arrivalTime release];
	arrivalTime = [arrivalAt copy];
}

- (void) setArrivalTimeWithInterval: (NSTimeInterval) arrivalAt
{
	//[arrivalTime release];
	//arrivalTime = [[NSDate dateWithTimeIntervalSince1970: arrivalAt] retain];
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

- (NSString *) route
{
	return route;
}

- (void) setRoute: (NSString *) route_name
{
	[route release];
	route = [route_name copy];
}

- (NSString *) stopId
{
	return stopId;
}

- (void) setStopId: (NSString *) stop
{
	[stopId release];
	stopId = [stop copy];
}

#pragma mark Archiver/UnArchiver Functions

- (id) initWithCoder: (NSCoder *) coder
{
	[super init];
	stopId = [[coder decodeObjectForKey:Arrival_Key_StopId] retain];
	busSign = [[coder decodeObjectForKey:Arrival_Key_BusSign] retain];
	arrivalTime = nil;
	departed = NO;
	flag = YES;
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:stopId forKey:Arrival_Key_StopId];
	[coder encodeObject:busSign forKey:Arrival_Key_BusSign];
}
	
@end
