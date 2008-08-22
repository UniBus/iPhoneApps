//
//  ClosestViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ClosestViewController.h"
#import "TransitApp.h"

@implementation ClosestViewController

- (void)loadView 
{
	[super loadView];
	stopViewType = kStopViewTypeToAdd;	

	double testLon = -122.60389;
	double testLat = 45.379719;
	double testDist = 0.1;
	
	CGPoint queryPos = CGPointMake(testLon, testLat);
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];	
	stopsOfInterest = [[myApplication closestStopsFrom:queryPos within:testDist] retain];
	
	[self reload];
}

@end

