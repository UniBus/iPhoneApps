//
//  RouteStops.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 01/08/09.
//  Copyright 2009 Zhenwang Yao. All rights reserved.
//

#import <sqlite3.h>

///Search/query for stops in the route_stops table.
/*!
 * \ingroup gtfsquery
 */ 
@interface RouteStops : NSObject {
	sqlite3 *database;
}

//Create an object with the route_stop sqlite3 file
+ (id) initWithFile:(NSString *) routeStopsFile;
- (BOOL) openRouteStopsFile: (NSString *)routeStopsFile;

/** @name Search/query for route stops
 *
 *  These functions query stops along routes, and their names are pretty self-explainatory.
 */
//@{
- (BOOL) isStop:(NSString *)stop_id hasRoutes:(NSArray *)routes;
//@}

@end
