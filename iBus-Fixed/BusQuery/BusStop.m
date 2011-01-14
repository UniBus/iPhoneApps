//
//  BusStop.m
//  StopQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "BusStop.h"
#import "General.h"

double UserDefinedLongitudeForComparison = 0.;
double UserDefinedLatitudeForComparison = 0.;

#define  Stop_Key_ID     @"ID"
#define  Stop_Key_LON    @"LON"
#define  Stop_Key_LAT    @"LAT"
#define  Stop_Key_NAME   @"NAME"
#define  Stop_Key_DES    @"Description"

@implementation BusStop
@synthesize stopId, latitude, longtitude, name, description, flag;

#pragma mark Comparison Tools

/*! \brief Comparison by Id.
 *
 * \param aStop A given stop to compare with.
 * \return
 *		- NSOrderedAscending, if self.stopId is bigger than aStop.stopId
 *		- NSOrderedDescending, if self.stopId is smaller than aStop.stopId
 *		- NSOrderedSame, if they are equal.
 */
- (NSComparisonResult) compareById: (BusStop *) aStop
{
	if (stopId < aStop->stopId)
		return NSOrderedAscending;
	else if (stopId > aStop->stopId)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

/*! \brief Comparison by latitude.
 *
 * \param aStop A given stop to compare with.
 * \return
 *		- NSOrderedAscending, if self.latitude is bigger than aStop.latitude
 *		- NSOrderedDescending, if self.latitude is smaller than aStop.latitude
 *		- NSOrderedSame, if they are equal.
 * \note
 *		If the longitude are equal, then the latitude will be compared.
 */
- (NSComparisonResult) compareByLat: (BusStop *) aStop
{
	if (latitude < aStop->latitude)
		return NSOrderedAscending;
	else if (latitude > aStop->latitude)
		return NSOrderedDescending;
	else
	{
		if (longtitude < aStop->longtitude)
			return NSOrderedAscending;
		else if (longtitude > aStop->longtitude)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}
}

/*! \brief Comparison by longitude.
 *
 * \param aStop A given stop to compare with.
 * \return
 *		- NSOrderedAscending, if self.longitude is bigger than aStop.longitude
 *		- NSOrderedDescending, if self.longitude is smaller than aStop.longitude
 *		- NSOrderedSame, if they are equal.
 * \note
 *		If the longitude are equal, then the latitude will be compared.
 */
- (NSComparisonResult) compareByLon: (BusStop *) aStop
{
	if (longtitude < aStop->longtitude)
		return NSOrderedAscending;
	else if (longtitude > aStop->longtitude)
		return NSOrderedDescending;
	else
	{
		if (latitude < aStop->latitude)
			return NSOrderedAscending;
		else if (latitude > aStop->latitude)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}
}

/*! \brief Comparison by distanct to a global point.
 *
 * \param aStop A given stop to compare with.
 * \return
 *		- NSOrderedAscending, if self.longitude is bigger than aStop.longitude
 *		- NSOrderedDescending, if self.longitude is smaller than aStop.longitude
 *		- NSOrderedSame, if they are equal.
 * \remarks
 *		- It compares with respect to distance to a global point 
 *				(UserDefinedLongitudeForComparison, UserDefinedLatitudeForComparison),
 *			and this should be set before using this function.
 * \todo
 *		Don't like the global point, should find a better way. Or at least put it as a class member.
 */
- (NSComparisonResult) compareByDistance: (BusStop *) aStop
{
	double ownDistance = distance(UserDefinedLatitudeForComparison, UserDefinedLongitudeForComparison, latitude, longtitude);
	double stopDistance = distance(UserDefinedLatitudeForComparison, UserDefinedLongitudeForComparison, [aStop latitude], [aStop longtitude]);
	
	if (ownDistance < stopDistance)
		return NSOrderedAscending;
	else if (ownDistance > stopDistance)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (void) dealloc
{
	[stopId release];
	[name release];
	[description release];
	[super dealloc];
}

#pragma mark Archiver/UnArchiver Functions
/** @name Encoder/decoder for copying
 *
 * 
 */
//@{
/*!
 *\todo This function should be deleted. 
 */
- (id) initWithCoder: (NSCoder *) coder
{
	[super init];
	[name autorelease];
	[description autorelease];
	
	stopId = [[coder decodeObjectForKey:Stop_Key_ID] retain];
	longtitude = [coder decodeDoubleForKey:Stop_Key_LON];
	latitude = [coder decodeDoubleForKey:Stop_Key_LAT];
	name = [[coder decodeObjectForKey:Stop_Key_NAME] retain];
	description = [[coder decodeObjectForKey:Stop_Key_DES] retain];
	
	return self;
}

/*!
 *\todo This function should be deleted. 
 */
- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:stopId forKey:Stop_Key_ID];
	[coder encodeDouble:longtitude forKey:Stop_Key_LON];
	[coder encodeDouble:latitude forKey:Stop_Key_LAT];
	[coder encodeObject:name forKey:Stop_Key_NAME];
	[coder encodeObject:description forKey:Stop_Key_DES];
}
//@}

@end
