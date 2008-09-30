//
//  iBus_UniversalAppDelegate.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "TransitAppDelegate.h"
#import "TransitApp.h"
#import "StopsViewController.h"

@implementation TransitAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)dataDidFinishLoading:(id)data
{
	if (window == nil)
		return;
	
	if ([window isHidden])
		return;

	UIViewController *selectedViewController = [tabBarController selectedViewController];
	if ([selectedViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navigController = (UINavigationController *)selectedViewController;
		if ([navigController.visibleViewController isKindOfClass:[StopsViewController class]])
		{
			//[(StopsViewController *)(navigController.visibleViewController) testFunction];
			[(StopsViewController *)(navigController.visibleViewController) needsReload];
		}
	}	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// Add the tab bar controller's current view as a subview of the window
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	//int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
	//if (selectedPage < [tabBarController.viewControllers count])
	//	tabBarController.selectedIndex = selectedPage;
	
    [window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];
	
	//if ([application isKindOfClass:[TransitApp class]])
	//{
	//	[(TransitApp *)application loadStopDataInBackground];
	//}
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

