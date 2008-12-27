//
//  GTFSCity.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 25/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "GTFSCity.h"


@implementation GTFS_City
@synthesize cid, cname, cstate, country, website, dbname, lastupdate, oldbtime, local;

- (void)dealloc 
{
	[cid release];
	[cname release];
	[cstate release];
	[country release];
	[website release];
	[dbname release];
	[lastupdate release];
	[oldbtime release];
	[super dealloc];
}

@end

