//
//  TripMapViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TripMapViewController.h"


@implementation TripMapViewController

- (void)mapWithTrip: (NSString *)tripId;
{
	NSString *urlString = [NSString stringWithFormat:@"http://zyao.servehttp.com:8888/ver1.1/portland/routemap.php?trip_id=%@", tripId];
	NSURL *url= [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:20];  // 20 sec;
	[mapWeb loadRequest:request];
	
	lastRequestedLat = 0;
	lastRequestedLon = 0;
}

@end
