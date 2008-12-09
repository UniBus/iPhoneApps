//
//  TripMapViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TripMapViewController.h"
#import "TransitApp.h"

@implementation TripMapViewController

- (void)mapWithTrip: (NSString *)tripId;
{
	NSString *currentWebSite = [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix];
	NSString *urlString = [NSString stringWithFormat:@"%@routemap.php?trip_id=%@", currentWebSite, tripId];
	NSURL *url= [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:20];  // 20 sec;
	[mapWeb loadRequest:request];
}

@end
