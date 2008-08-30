//
//  StopQuery-ARV.m
//  DataProcess
//
//  Created by Zhenwang Yao on 22/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopQuery-ARV.h"


@implementation StopQuery_ARV

+ (id) initWithFile:(NSString *) stopFile
{
	StopQuery_ARV *newObj;
	newObj = [[StopQuery_ARV alloc] init];
	if (newObj == nil)
		return nil;
	
	if ([newObj openStopFile:stopFile])
		return newObj;
	
	[newObj release];
	NSLog(@"%d", errno);
	return nil;
}

- (BOOL) openStopFile: (NSString *)stopFile
{
	[sortedStops release];
    NSString *path = [NSString stringWithFormat:@"%@.arv", stopFile];
	sortedStops = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
	return (sortedStops != nil);
}

@end
