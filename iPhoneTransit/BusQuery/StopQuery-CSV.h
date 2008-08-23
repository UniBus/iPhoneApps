//
//  StopQuery-CSV.h
//  DataProcess
//
//  Created by Zhenwang Yao on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "StopQuery.h"

@interface StopQuery_CSV : StopQuery {
	NSMutableArray *rawStops;	

}

- (BOOL) openStopFile: (NSString *)stopFile;
- (BOOL) saveStopFile: (NSString *)stopFile;

@end
