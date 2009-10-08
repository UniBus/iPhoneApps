//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
/**
 * \defgroup gtfsquery GTFS query
 *
 * These classes query information based on GTFS data or GTFS server.
 */

/*! \class ArrivalQuery
 *
 * \brief XML query/paser for bus arrivals. 
 *
 * The returning XML is of the following format:
 * \code 
 *   <resultSet city="Portland" queryTime="01:41:07">
 *     <arrival stop_id="10324" route_id="33" route_name="33" bus_sign="Oregon City TC" direction_id="0" arrival_time="08:44:00"/>
 *     <arrival stop_id="10324" route_id="33" route_name="33" bus_sign="Oregon City TC" direction_id="0" arrival_time="09:49:00"/>
 *     <arrival stop_id="10324" route_id="99" route_name="99" bus_sign="McLoughlin Express" direction_id="0" arrival_time="--:--:--"/>
 *   </resultSet>
 * \endcode
 *
 * \ingroup xmlquery
 * \ingroup gtfsquery
 */

#import "ArrivalQuery.h"
#import "BusArrival.h"

@implementation ArrivalQuery

- (id) init
{
	[super init];
	arrivalsForStops = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	[arrivalsForStops release];
	[super dealloc];
}

#pragma mark Stop Querys
/*!
 * \brief Return TODAY's whole-day schedule for the given [route, direction] at the given stop.
 *
 * \param route The given route (route_id).
 * \param dir The given direction (direction_id).
 * \param stop The given stop (stop_id).
 * \return 
 *		An array of arrivals. Empty array, in case there is no bus running for today.
 */
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop
{
	NSString *urlString = [NSString stringWithFormat:@"%@/schedules.php?stop_id=%@&route_id=%@&direction_id=%@",
						   webServicePrefix, stop, route, dir];
	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	
	[arrivalsForStops removeAllObjects];
	[self queryByURL:queryURL];	
	return arrivalsForStops;
}

/*!
 * \brief Return whole-day schedule of the given day for the given [route, direction] at the given stop.
 *
 * \param route The given route (route_id).
 * \param dir The given direction (direction_id).
 * \param stop The given stop (stop_id).
 * \param day The given day (in form of 'YYYYMMDD').
 * \return 
 *		An array of arrivals. Empty array, in case there is no bus running for today.
 */
//- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop onDay:(NSString *)day
- (NSArray *) queryForRoute: (NSString *)route inDirection:(NSString *)dir atStop:(NSString *)stop onDay:(NSString *)day
{
	NSString *urlString = [NSString stringWithFormat:@"%@/schedules.php?stop_id=%@&direction_id=%@&route_id=%@&day=%@",
						   webServicePrefix, stop, dir, route, day];
	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	
	[arrivalsForStops removeAllObjects];
	[self queryByURL:queryURL];	
	return arrivalsForStops;
}

/*!
 * \brief Return all arrivals at the given stops.
 *
 * \param stops An array of given stops (stop_ids). 
 * \return 
 *		An array of arrivals. Empty array, in case there is no bus running possibly stops at these stops.
 * \remark
 *      In current design, all buses possibly passing a stop will be listed under the stop, even if there
 *         is no arrivals during the query period, under which case, the arrival is faked as "-- -- --".
 */
- (NSArray *) queryForStops: (NSArray*) stops
{
	if ([stops count] == 0)
		return nil;
	
	NSString *idListString = [NSString stringWithFormat:@"%@", [[stops objectAtIndex:0] stopId]];
	for (int i=1; i<[stops count]; i++)
		idListString = [NSString stringWithFormat:@"%@,%@", idListString, [[stops objectAtIndex:i] stopId]];
	
	NSString *urlString = [NSString stringWithFormat:@"%@/arrivals.php?stop_id=%@",
							self.webServicePrefix, idListString];
	
	//NSString * encodedString = (NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
	//																				  (CFStringRef)urlString,
	//																				  CFSTR(""));
	//Clearly the above is a better way, but unfortunately,
	//   current SDK doesn't work for that!!
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	
	[arrivalsForStops removeAllObjects];
	[self queryByURL:queryURL];
	return arrivalsForStops;
}

/*!
 * \brief Get schedule/arrivals for just one stop.
 *
 * Based on the previous query results, retrieve arrivals/schedule for one single stop.
 *
 * \todo
 *      Apparently this function has no use. Delete this function.
 */
- (NSArray *) scheduleForStop:(NSString *) stopId
{
	int numOfArrivals = [arrivalsForStops count];
	if (numOfArrivals == 0)
		return nil;
	
	int lowerIndex = 0;
	int upperIndex =  - 1;
	
	for (int i=0; i<=upperIndex; i++)
		if ([[arrivalsForStops objectAtIndex:i] stopId] == stopId)
		{
			lowerIndex = i;
			break;
		}

	for (int i=upperIndex; i<=0; i--)
		if ([[arrivalsForStops objectAtIndex:i] stopId] == stopId)
		{
			upperIndex = i;
			break;
		}
	
	if (lowerIndex > upperIndex)
		return nil;
	
	return [arrivalsForStops objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lowerIndex, upperIndex-lowerIndex+1)]];
}

#pragma mark XML Delegate Callback Functions
/*!
 * \brief Parse the returning XML.
 *
 * See the above XML format.
 *
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"arrival"]) 
	{
		BusArrival *arrival = [[BusArrival alloc] init];
		[arrival setStopId: [attributeDict valueForKey:@"stop_id"]];
		[arrival setRouteId:[attributeDict valueForKey:@"route_id"]];
		[arrival setRoute:[attributeDict valueForKey:@"route_name"]];
		[arrival setArrivalTime:[attributeDict valueForKey:@"arrival_time"]];
		[arrival setBusSign:[attributeDict valueForKey:@"bus_sign"]];
		[arrival setDirection:[attributeDict valueForKey:@"direction_id"]];
		
		[arrivalsForStops addObject:arrival];
		[arrival release];
	}
}

@end
