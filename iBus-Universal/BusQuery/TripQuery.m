//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
/*! \class TripQuery
 *
 * \brief XML query/paser for trips of a route, and stops of a trip. 
 *
 * The returning XML for tripsofroute.php?route_id=xxxx is of the following format:
 * \code 
 *   <resultSet city="Portland" queryTime="10:50:12">
 *     <trip route_id="33" trip_id="330S1010" direction_id="0" trip_headsign="Direction 0"/>
 *     <trip route_id="33" trip_id="331S1010" direction_id="1" trip_headsign="Direction 1"/>
 *   </resultSet>
 * \endcode
 *
 * The returning XML for stopsofroute.php?trip_id=xxxx is of the following format:
 * \code 
 *   <resultSet city="Portland" queryTime="10:54:05">
 *     <stop trip_id="330s1010" stop_id="12779"/> 
 *     <stop trip_id="330s1010" stop_id="12782"/>
 *       .... more bus stops ...
 *     <stop trip_id="330s1010" stop_id="1068"/>
 *   </resultSet>
 * \endcode
 *
 * \ingroup xmlquery
 * \ingroup gtfsquery
*/
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
/*!
 * \brief Return all different trips for a route.
 *
 * \param routeId The given route (route_id). 
 * \return 
 *		An array of trips. Empty array, in case there is no trips availabe.
 * \remark
 *      - The result should have nothing to do with query time/period, and should include possible trips of any time.
 *      - The result is somewhat depending on GTFS data. I mean, some agencies put trips to different destinations
 *          under a same route with same direction, while other may distinguish them by using differnt route_id.
 * \todo
 *     Server side, when querying for trips, please double check if it is possible to group the trip
 *       by trip_headsign, such that trips to differnt destinations can be distinguished.
 */
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


/*!
 * \brief Return all stops in a trip.
 *
 * \param tripId The given trip (trip_id). 
 * \return 
 *		An array of stops. Empty array, in case there is no stop availabe.
 *
 */
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
/*!
 * \brief Parse the returning XML.
 *
 * This function handle two different XMLs, (i) returned from tripsofroute.php and (ii) returned from routesoftrip.php.
 *
 * See the above XML format.
 *
 */
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
