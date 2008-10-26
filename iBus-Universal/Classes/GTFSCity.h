//
//  GTFSCity.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 25/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTFS_City : NSObject
{
	NSString *cid;
	NSString *cname;
	NSString *cstate;
	NSString *country;
	NSString *website;
	NSString *dbname;
	NSString *lastupdate;
	NSInteger local;
}

@property (retain) NSString *cid;
@property (retain) NSString *cname;
@property (retain) NSString *cstate;
@property (retain) NSString *country;
@property (retain) NSString *website;
@property (retain) NSString *dbname;
@property (retain) NSString *lastupdate;
@property NSInteger			local;

@end

