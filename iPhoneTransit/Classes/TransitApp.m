//
//  TransitApp.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransitApp.h"
#import "iPhoneTransitAppDelegate.h"

enum _supported_city {
	kCity_Portland,
	kCity_Num,	
};

NSString *cityPath[]={
	@"portland",
};

NSString * const UserSavedRecentStopsAndBuses = @"UserSavedRecentStopsAndBuses";
NSString * const UserSavedFavoriteStopsAndBuses = @"UserSavedFavoriteStopsAndBuses";
NSString * const UserSavedSearchRange = @"UserSavedSearchRange";
NSString * const UserSavedSearchResultsNum = @"UserSavedSearchResultsNum";

extern float searchRange;
extern int numberOfResults;

@interface TransitApp ()
- (void) loadDataInBackground;
- (void) dataTaskEntry: (id) data;
@end


@implementation TransitApp

@synthesize queryAvailable;

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
	dataFile = [path retain];
	
	//stopQuery = [StopQuery initWithFile:path];
	//arrivalQuery = [[ArrivalQuery alloc] init];
	//queryAvailable = YES;
	opQueue = [[NSOperationQueue alloc] init];
	[self loadDataInBackground];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	NSMutableArray *emptyArray = [NSMutableArray array];
	[defaultValues setObject:emptyArray forKey:UserSavedRecentStopsAndBuses];
	[defaultValues setObject:emptyArray forKey:UserSavedFavoriteStopsAndBuses];
	[defaultValues setObject:[NSNumber numberWithFloat:searchRange] forKey:UserSavedSearchRange];
	[defaultValues setObject:[NSNumber numberWithInt:numberOfResults] forKey:UserSavedSearchResultsNum];
	[defaults registerDefaults:defaultValues];
	
	return self;
}

- (void) dealloc
{
	[opQueue cancelAllOperations];
	[opQueue autorelease];
	[arrivalQuery release];
	[stopQuery release];
	[super dealloc];
}

- (int) numberOfStops
{
	if (stopQuery == nil)
		return 0;
	else
		return [stopQuery numberOfStops];
}

- (BusStop *) stopOfId:(int) anId
{
	if (stopQuery == nil)
	{
		return nil;
	}	
	return [stopQuery stopOfId:anId];
}

- (NSArray *) closestStopsFrom:(CGPoint) pos within:(double)distInKm
{
	if (stopQuery == nil)
	{
		return [NSMutableArray array];
	}
	return [stopQuery queryStopWithPosition:pos within:distInKm];
}

- (NSArray *) arrivalsAtStops: (NSArray*) stops
{
	if (arrivalQuery == nil)
	{
		return [NSMutableArray array];
	}
	return [arrivalQuery queryForStops:stops];
}

#pragma mark A Task to load in data files
- (void) loadDataInBackground
{
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(dataTaskEntry:) object:nil];
	
	[opQueue addOperation:theOp];
}

- (void) dataTaskEntry: (id) data
{
	StopQuery *tmpStopQuery = [StopQuery initWithFile:dataFile];
	if (tmpStopQuery == nil)
		return;
	
	ArrivalQuery *tmpArrivalQuery = [[ArrivalQuery alloc] init];
	if (tmpArrivalQuery == nil)
	{
		[tmpStopQuery release];
		tmpStopQuery = nil;
		return;
	}
	
	stopQuery = tmpStopQuery;
	arrivalQuery = tmpArrivalQuery;
	queryAvailable = YES;
	
	iPhoneTransitAppDelegate *transitDelegate = (iPhoneTransitAppDelegate *)[self delegate];
	[transitDelegate dataDidFinishLoading:self];
}

@end
