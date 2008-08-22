//
//  MetronomeAppDelegate.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MetronomeAppDelegate.h"
#import "MetronomeViewController.h"

@implementation MetronomeAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	// Override point for customization after app launch	
    [window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	//User defaults registering

    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
    // Put defaults in the dictionary
	[defaultValues setObject:[NSNumber numberWithInt:viewController.selectedBPM] forKey:MUSDefaultBPM];
	[defaultValues setObject:[NSNumber numberWithInt:viewController.selectedRythm] forKey:MUSDefaultRythm];
		
    // Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}

/*
- (void)applicationWillTerminate:(UIApplication *)application
{
}
*/

- (void)dealloc {
    [viewController release];
	[window release];
	[super dealloc];
}


@end
