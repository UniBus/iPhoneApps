//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <SystemConfiguration/SCNetworkReachability.h>
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

- (BOOL) available
{
	NSURL *targetingUrl = [NSURL URLWithString:webServicePrefix];
	SCNetworkReachabilityFlags        flags;
    SCNetworkReachabilityRef reachability =  SCNetworkReachabilityCreateWithName(NULL, [[targetingUrl host] UTF8String]);
    BOOL gotFlags = SCNetworkReachabilityGetFlags(reachability, &flags);    
	CFRelease(reachability);
	if (!gotFlags) {
        return NO;
    }
    
    return flags & kSCNetworkReachabilityFlagsReachable;
}

#pragma mark Stop Querys

- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop
{
	NSString *urlString = [NSString stringWithFormat:@"%@/schedules.php?stop_id=%@&route_id=%@",
						   webServicePrefix, stop, route];
	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	
	[arrivalsForStops removeAllObjects];
	[self queryByURL:queryURL];	
	return arrivalsForStops;
}

- (NSArray *) queryForRoute: (NSString *)route atStop:(NSString *)stop onDay:(NSString *)day
{
	NSString *urlString = [NSString stringWithFormat:@"%@/schedules.php?stop_id=%@&route_id=%@&day=%@",
						   webServicePrefix, stop, route, day];
	
	NSString * encodedString = [urlString stringByReplacingOccurrencesOfString: @" "withString: @"%20"];
	NSURL *queryURL = [NSURL URLWithString:encodedString];
	
	[arrivalsForStops removeAllObjects];
	[self queryByURL:queryURL];	
	return arrivalsForStops;
}

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
		
		[arrivalsForStops addObject:arrival];
		[arrival release];
	}
}

@end
