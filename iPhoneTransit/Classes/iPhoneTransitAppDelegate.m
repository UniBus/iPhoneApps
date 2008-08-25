//
//  iPhoneTransitAppDelegate.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "iPhoneTransitAppDelegate.h"
#import "ClosestViewController.h"
#import "RecentViewController.h"
#import "FavoriteViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "TransitApp.h"


@implementation iPhoneTransitAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)dataDidFinishLoading:(UIApplication *)application
{
	if (window == nil)
		return;
	
	if ([window isHidden])
		return;
	
	UIViewController *selectedViewController = [tabBarController selectedViewController];
	if ([selectedViewController isKindOfClass:[StopsViewController class]])
		[(StopsViewController *)selectedViewController needsReload];
	
	if ([application isKindOfClass:[TransitApp class]])
	{
		TransitApp *myApp = (TransitApp *)application;
		if (myApp.arrivalQueryAvailable && myApp.stopQueryAvailable)
		{
			[indicator stopAnimating];
			[indicator removeFromSuperview];
		}
	}
	else
	{
		if ([indicator isAnimating])
		{
			[indicator stopAnimating];
			[indicator removeFromSuperview];
		}
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Add the tab bar controller's current view as a subview of the window
    [window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];
	[window addSubview:indicator];
	[indicator startAnimating];
	
	if ([application isKindOfClass:[TransitApp class]])
	{
		[(TransitApp *)application loadStopDataInBackground];
	}
}


/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

