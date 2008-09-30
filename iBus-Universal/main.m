//
//  main.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitApp.h"
#import "TransitAppDelegate.h"

int main(int argc, char *argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, @"TransitApp", @"TransitAppDelegate");
	[pool release];
	return retVal;
}

