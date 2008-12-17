//
//  StopMapViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StopMapViewController.h"
#import "TransitApp.h"

@implementation StopMapViewController

- (void)mapWithLatitude: (double)lat Longitude:(double)lon
{
	//NSString *urlString = [NSString stringWithFormat:@"http://zhenwang.yao.googlepages.com/maplet.html?width=%f&height=%f&lat=%f&long=%f", 
	//					   self.view.frame.size.width, self.view.frame.size.height, lat, lon];
	NSString *currentWebSite = [(TransitApp *)[UIApplication sharedApplication] currentWebServicePrefix];
	NSString *urlString = [NSString stringWithFormat:@"%@stopmap.php?lat=%f&long=%f", 
						  currentWebSite, lat, lon];
	
	
	//NSURL *url = [NSURL URLWithString:@"http://zhenwang.yao.googlepages.com/maplet.html"];
	NSURL *url= [NSURL URLWithString:urlString];
	
	[super mapWithURL:url];
	//NSURLRequest *request = [NSURLRequest requestWithURL:url 
	//										 cachePolicy:NSURLRequestUseProtocolCachePolicy
	//									 timeoutInterval:20];  // 20 sec;
	//[mapWeb loadRequest:request];
}

@end
