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


@implementation iPhoneTransitAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)dataDidFinishLoading:(UIApplication *)application
{
	[indicator stopAnimating];
	[indicator removeFromSuperview];
	UIViewController *selectedViewController = [tabBarController selectedViewController];
	if ([selectedViewController isKindOfClass:[StopsView class]])
		[(StopsView *)selectedViewController needsReload];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Add the tab bar controller's current view as a subview of the window
    [window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];
	[window addSubview:indicator];
	[indicator startAnimating];
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

