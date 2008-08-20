//
//  TransitApp.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransitApp.h"

enum _supported_city {
	kCity_Portland,
	kCity_Num,	
};

NSString *cityPath[]={
	@"portland",
};

@implementation TransitApp

- (id) init
{
	[super init];
	
	cityId = kCity_Portland;
	
    // The stop data is stored in the application bundle. 
    //NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsDirectory = [[NSBundle mainBundle] resourcePath];
	NSString *filename = [NSString stringWithFormat:@"%@_stops.txt", cityPath[cityId]];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	NSLog(@"Opening file: %@", path);
	
	stopQuery = [StopQuery initWithFile:path];
	arrivalQuery = [[ArrivalQuery alloc] init];

	return self;
}

- (void) dealloc
{
	[arrivalQuery release];
	[stopQuery release];
	[super dealloc];
}

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm
{
	return [stopQuery queryStopWithPosition:pos within:distInKm];
}

- (NSArray *) arrivalsAtStops: (NSArray*) stops
{
	return [arrivalQuery queryForStops:stops];
}

@end
