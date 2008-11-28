//
//  StopMapViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopMapViewController.h"


@implementation StopMapViewController

- (void)mapWithLatitude: (double)lat Longitude:(double)lon
{
	//NSString *urlString = [NSString stringWithFormat:@"http://www.wenear.com/iphone-test?width=%f&height=%f", 
	//					   self.view.frame.size.width, self.view.frame.size.height];
	NSString *urlString = [NSString stringWithFormat:@"http://zhenwang.yao.googlepages.com/maplet.html?width=%f&height=%f&lat=%f&long=%f", 
						   self.view.frame.size.width, self.view.frame.size.height, lat, lon];
	
	//NSURL *url = [NSURL URLWithString:@"http://zhenwang.yao.googlepages.com/maplet.html"];
	NSURL *url= [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:20];  // 20 sec;
	[mapWeb loadRequest:request];
	
	lastRequestedLat = lat;
	lastRequestedLon = lon;
}

@end
