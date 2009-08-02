//
//  RouteQuery.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <sqlite3.h>
#import "BusRoute.h"

///Search/query for routes in the routes table.
/*!
 * \ingroup gtfsquery
 */ 
@interface RouteQuery : NSObject{
	sqlite3 *database;
}

//Create an object with the route file
+ (id) initWithFile:(NSString *) routeFile;
- (BOOL) openRouteFile: (NSString *)routeFile;

/** @name Search/query for routes and trips
 *
 *  These functions query routes and related information, and their names are pretty self-explainatory.
 */
//@{
- (NSInteger) typeOfRoute: (NSString *) routeId;
- (BusRoute *) routeOfId: (NSString *) sid;
- (NSArray *) queryRouteWithName:(NSString *) routeName;
- (NSArray *) queryRouteWithNames:(NSArray *) routeNames;
- (NSArray *) queryRouteWithIds:(NSArray *) routeIds;
//@}

@end
