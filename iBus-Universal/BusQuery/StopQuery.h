//
//  StopQuery-CSV.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "BusStop.h"

///Search/query for stops in the stops table.
/*!
 * \ingroup gtfsquery
 */ 
@interface StopQuery : NSObject{
	sqlite3 *database;
}

//Create an object with the stop file
+ (id) initWithFile:(NSString *) stopFile;
- (BOOL) openStopFile: (NSString *)stopFile;

//Query
- (BusStop *) getRandomStop;

/** @name Comparison functions for sorting.
 *
 *  These functions compare self with anohter given stop.
 */
//@{
/// Find a stop of the given stop id.
- (BusStop *) stopOfId: (NSString *) sid;

/// Find stops within a certain range of the given location.
- (NSArray *) queryStopWithPosition:(CGPoint) pos within:(double)distInKm;

//!\brief Find stops with a keyword.
- (NSArray *) queryStopWithName:(NSString *) stopName;

//!\brief Find stops with a set of keywords.
- (NSArray *) queryStopWithNames:(NSArray *) stopNames;

//!\brief Find stops of given set of stop ids.
- (NSArray *) queryStopWithIds:(NSArray *) stopIds;
//@}

@end
