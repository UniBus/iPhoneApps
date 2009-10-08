//
//  main.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright Zhenwang Yao. 2008. All rights reserved.
//

/*! @mainpage UniBus

 @section history History

 This was the second idea of my iPhone application development.
 
 At the very first, the idea was to provide schedule for local Vancouver user, but
   it turned out some local company (HandiMobility) is hogging the data, and seemed
   like Translink is unwilling to make the data public, due to proprietary issue.
 
 I didn't want to scrap the data from Translink, because 
 (i) didn't quite know how to do it.
 (ii) stop locations (lon, lat) are not available for scrapping
 (iii) time should be spent in a better place.
 
 I then found out there are public transit data aviable through Google Transit Feed, 
 and even better, Triment of Portland, OR, has been providing webservice for developers.
 So, I spent time to make my first Tansit application, iBus-Portland, using Trimet.org
 webservice.

 Later on, I think it is a better idea to have a general application that can provide
 service to those cities, as long as they have public transit data. That is UniBus.
 
*/

#import <UIKit/UIKit.h>
#import "TransitApp.h"
#import "TransitAppDelegate.h"

int main(int argc, char *argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, @"TransitApp", @"TransitAppDelegate");
	[pool release];
	return retVal;
}

