//
//  MetronomeAppDelegate.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MetronomeAppDelegate.h"
#import "RootViewController.h"
#import "MetronomeViewController.h"

@implementation MetronomeAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	//User defaults registering
	
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
    // Put defaults in the dictionary
	[defaultValues setObject:[NSNumber numberWithInt:viewController.metronomeViewController.selectedBPM] forKey:MUSDefaultBPM];
	[defaultValues setObject:[NSNumber numberWithInt:viewController.metronomeViewController.selectedRythm] forKey:MUSDefaultRythm];
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:MUSDefaultDownbeat];
	[defaultValues setObject:[NSNumber numberWithInt:1] forKey:MUSDefaultUpbeat];
	[defaultValues setObject:[NSNumber numberWithFloat:1.] forKey:MUSDefaultVolume];
	
    // Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
	// Override point for customization after app launch	
    // Set up main view controller 
    RootViewController *tmpViewController = [[RootViewController alloc] init];
    self.viewController = tmpViewController;
    [window addSubview:viewController.view];
    [tmpViewController release];

	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[application setIdleTimerDisabled:NO];
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
