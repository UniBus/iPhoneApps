//
//  ArrivalQuery.m
//  StopQuery
//
//  Created by Zhenwang Yao on 17/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ArrivalQuery.h"
#import "BusArrival.h"

NSString const *globalAppID = @"9DC07B30ADE677EC5DE272F8A";

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

- (NSArray *) queryForStops: (NSArray*) stops
{
	if ([stops count] == 0)
		return nil;
	
	NSString *idListString = [NSString stringWithFormat:@"%d", [[stops objectAtIndex:0] stopId]];
	for (int i=1; i<[stops count]; i++)
		idListString = [NSString stringWithFormat:@"%@,%d", idListString, [[stops objectAtIndex:i] stopId]];
	
	NSString *urlString = [NSString stringWithFormat:@"http://developer.trimet.org/ws/V1/arrivals?locIDs=%@&appID=%@",
							idListString, globalAppID];
	
	NSURL *queryURL = [NSURL URLWithString:urlString];
	return [self queryByURL:queryURL];
}

- (NSArray *) queryByURL: (NSURL *) url
{
	[arrivalsForStops removeAllObjects];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError) {
		NSLog(@"Error: %@", parseError);
    }
    
    [parser release];
	
	return arrivalsForStops;
}

- (NSArray *) scheduleForStop:(NSInteger) stopId
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

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[arrivalsForStops sortUsingSelector:@selector(compare:)];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"arrival"]) 
	{
		BusArrival *arrival = [[BusArrival alloc] init];
		arrival.stopId = [[attributeDict valueForKey:@"locid"] intValue];
		arrival.departed = [[attributeDict valueForKey:@"departed"] boolValue];
		[arrival setArrivalTimeWithInterval:[[attributeDict valueForKey:@"scheduled"] doubleValue]/1000. ];
		[arrival setBusSign:[attributeDict valueForKey:@"shortSign"]];
		
		[arrivalsForStops addObject:arrival];
		[arrival autorelease];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	return;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	return;
}

@end
