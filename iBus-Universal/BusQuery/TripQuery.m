//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "TripQuery.h"
#import "BusTrip.h"
#import "BusRoute.h"
enum QueryType {
	kQuery_None = -1,
	kQuery_TripsOnRoute = 0,
	kQuery_StopsOnTrip
};

@implementation TripQuery

- (id) init
{
	[super init];
	tripsOnRoute = [[NSMutableArray alloc] init];
	stopsOnTrip = [[NSMutableArray alloc] init];
	currentQuery = kQuery_None;
	return self;
}

- (void) dealloc
{
	[stopsOnTrip release];
	[tripsOnRoute release];
	[super dealloc];
}

#pragma mark Trip Querys
- (NSArray *) queryTripsOnRoute:(NSString *) routeId
{
	NSString *urlString = [NSString stringWithFormat:@"%@/tripsofroute.php?route_id=%@", webServicePrefix, routeId];	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	queryingRoute = routeId;

	NSAssert( (currentQuery == kQuery_None), @"TripQuery in a wrong state!!");
	
	currentQuery = kQuery_TripsOnRoute;
	[tripsOnRoute removeAllObjects];
	[self queryByURL:queryURL];	
	currentQuery = kQuery_None;
	return tripsOnRoute;
}

- (NSArray *) queryStopsOnTrip:(NSString *) tripId
{
	NSString *urlString = [NSString stringWithFormat:@"%@/stopsoftrip.php?trip_id=%@", webServicePrefix, tripId];	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	queryingTrip = tripId;
	
	NSAssert( (currentQuery == kQuery_None), @"TripQuery in a wrong state!!");

	currentQuery = kQuery_StopsOnTrip;
	[stopsOnTrip removeAllObjects];
	[self queryByURL:queryURL];	
	currentQuery = kQuery_None;
	return stopsOnTrip;
}

#pragma mark XML Delegate Callback Functions
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSAssert( (currentQuery != kQuery_None), @"TripQuery in a wrong state!!");

	if (currentQuery == kQuery_StopsOnTrip)
	{
		if ([elementName isEqualToString:@"stop"]) 
		{
			NSString *receivedTripId = [attributeDict valueForKey:@"trip_id"];
			NSString *receivedStopId = [attributeDict valueForKey:@"stop_id"];
			
			NSAssert([receivedTripId isEqualToString:queryingTrip], @"Query results contain garbage!!");
			[stopsOnTrip addObject:receivedStopId];
		}
	}
	else if (currentQuery == kQuery_TripsOnRoute)
	{
		if ([elementName isEqualToString:@"trip"]) 
		{
			BusTrip *aTrip = [[BusTrip alloc] init];
			NSString *receivedRouteId = [attributeDict valueForKey:@"route_id"];
			aTrip.tripId = [attributeDict valueForKey:@"trip_id"];
			aTrip.direction = [attributeDict valueForKey:@"direction_id"];
			aTrip.headsign = [attributeDict valueForKey:@"trip_headsign"];
			
			NSAssert([receivedRouteId isEqualToString:queryingRoute], @"Query results contain garbage!!");
			[tripsOnRoute addObject:aTrip];
		}
	}
}

@end
