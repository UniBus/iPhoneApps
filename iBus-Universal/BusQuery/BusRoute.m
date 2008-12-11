//
//  BusRoute.m
//  RouteQuery
//
//  Created by Zhenwang Yao on 15/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BusRoute.h"
#import "General.h"

@implementation BusRoute
@synthesize routeId, name, description, type, flag;

#pragma mark Comparison Tools

- (void) dealloc
{
	[routeId release];
	[name release];
	[description release];
	[super dealloc];
}

@end
