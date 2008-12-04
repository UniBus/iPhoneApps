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
#import "StopSearchViewController.h"
#import "RouteSearchViewController.h"
#import "CitySelectViewController.h"
#import "FavoriteViewController.h"
#import "SettingsViewController.h"
#import "OfflineViewController.h"
#import "InfoViewController.h"
#import "CityUpdateViewController.h"
#import "NearbyViewController.h"

extern BOOL autoSwitchToOffline;
extern BOOL alwaysOffline;

NSString *tabBarViewControllerIds[]={
	@"FavoriteViewController",
	@"StopSearchViewController",
	@"RouteSearchViewController",
	@"NearbyViewController",
	@"SettingsViewController",
	@"CityUpdateViewController",
	@"OfflineViewController",
	@"InfoViewController",
};

@implementation TransitAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void) reorderViewController
{
	NSMutableArray *newViewControllerSequence = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
	NSArray *savedTabBarVCSequence = [[NSUserDefaults standardUserDefaults] objectForKey:UserSavedTabBarSequence];
	int currentIndex = 0;
	for (NSString *aViewCtrlName in savedTabBarVCSequence)
	{
		Class aClass;
		if ([aViewCtrlName isEqual:tabBarViewControllerIds[0]])
			aClass = [FavoriteViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[1]])
			aClass = [StopSearchViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[2]])
			aClass = [RouteSearchViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[3]])
			aClass = [NearbyViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[4]])
			aClass = [SettingsViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[5]])
			aClass = [CityUpdateViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[6]])
			aClass = [OfflineViewController class];
		else if ([aViewCtrlName isEqual:tabBarViewControllerIds[7]])
			aClass = [InfoViewController class];
		
		for (int index=currentIndex; index<[newViewControllerSequence count]; index++)
		{
			UINavigationController *viewControllerAtIndex = (UINavigationController *)[newViewControllerSequence objectAtIndex:index];
			
			NSAssert([viewControllerAtIndex isKindOfClass:[UINavigationController class]], @"All viewController in TabBar should be NaviationView");
			if ([viewControllerAtIndex.topViewController isKindOfClass:aClass])
			{
				[newViewControllerSequence exchangeObjectAtIndex:index withObjectAtIndex:currentIndex];
				break;
			}
		}
		currentIndex++;
	}
	tabBarController.viewControllers = newViewControllerSequence;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// Add the tab bar controller's current view as a subview of the window
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *selectedCityId = [defaults objectForKey:UserCurrentCityId];
	NSString *selectedCity = [defaults objectForKey:UserCurrentCity];
	NSString *selectedDatabase = [defaults objectForKey:USerCurrentDatabase];
	NSString *selectedWebPrefix = [defaults objectForKey:UserCurrentWebPrefix];
	
	autoSwitchToOffline = [defaults boolForKey:UserSavedAutoSwitchOffline];
	alwaysOffline = [defaults boolForKey:UserSavedAlwayOffline];
	
	// This is the first time it run the App.
	if ([selectedCity isEqualToString:@""] || [selectedDatabase isEqualToString:@""] || [selectedWebPrefix isEqualToString:@""])
	{
		
		CitySelectViewController *selectionVC = [[CitySelectViewController alloc] initWithNibName:nil bundle:nil];
		selectionVC.delegate = self;

		configController = [[UINavigationController alloc] initWithRootViewController:selectionVC];	
		configController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
		[window makeKeyWindow];
		[window addSubview:configController.view];
	}
	else
	{
		TransitApp *myApp = (TransitApp *)[UIApplication sharedApplication];
		NSAssert([myApp isKindOfClass:[TransitApp class]], @"Mismatched UIApplication type!!");

		[self reorderViewController];
		[myApp setCurrentCity:selectedCity cityId:selectedCityId database:selectedDatabase webPrefix:selectedWebPrefix];
		int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
		if (selectedPage < [tabBarController.viewControllers count])
			tabBarController.selectedIndex = selectedPage;
	
		tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		//tabBarController.moreNavigationController.editing = YES;
		//[tabBarController setEditing:NO animated:NO];
		//tabBarController.moreNavigationController.navigationItem.rightBarButtonItem=nil;
		
		[window makeKeyAndVisible];	
		[window addSubview:tabBarController.view];
		
		[self performSelectorInBackground:@selector(checkForUpdate) withObject:nil];
	}
}

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)theTabBar didSelectViewController:(UIViewController *)viewController 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults integerForKey:UserSavedSelectedPage] != tabBarController.selectedIndex)
		[defaults setInteger:tabBarController.selectedIndex forKey:UserSavedSelectedPage];
	
	//if (viewController == tabBarController.moreNavigationController)
	//{
	//	tabBarController.moreNavigationController.navigationItem.rightBarButtonItem = nil;
	//}
}


// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed 
{
	if (!changed)
		return;
	
	NSMutableArray *tabBarVCSequence = [NSMutableArray array];
	for(UINavigationController *aViewCtrl in viewControllers)
	{
		NSAssert([aViewCtrl isKindOfClass:[UINavigationController class]], @"All viewController in TabBar should be NaviationView");
		if ([aViewCtrl.topViewController isKindOfClass:[FavoriteViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[0]];
		else if ([aViewCtrl.topViewController isKindOfClass:[StopSearchViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[1]];
		else if ([aViewCtrl.topViewController isKindOfClass:[RouteSearchViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[2]];
		else if ([aViewCtrl.topViewController isKindOfClass:[NearbyViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[3]];
		else if ([aViewCtrl.topViewController isKindOfClass:[SettingsViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[4]];
		else if ([aViewCtrl.topViewController isKindOfClass:[CityUpdateViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[5]];
		else if ([aViewCtrl.topViewController isKindOfClass:[OfflineViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[6]];
		else if ([aViewCtrl.topViewController isKindOfClass:[InfoViewController class] ])
			[tabBarVCSequence addObject:tabBarViewControllerIds[7]];		
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:tabBarVCSequence forKey:UserSavedTabBarSequence];	
}

- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

- (void) citySelected:(id)sender
{
	TransitApp *myApp = (TransitApp *)[UIApplication sharedApplication];
	NSAssert([myApp isKindOfClass:[TransitApp class]], @"Mismatched UIApplication type!!");
	[myApp citySelected:sender];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int selectedPage = [defaults integerForKey:UserSavedSelectedPage];
	if (selectedPage < [tabBarController.viewControllers count])
		tabBarController.selectedIndex = selectedPage;
	
	[configController.view removeFromSuperview];
	[window makeKeyAndVisible];	
	[window addSubview:tabBarController.view];	
	[configController release];
	configController = nil;
}

- (void) cityDidChange
{
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			[(UINavigationController *)vc popToRootViewControllerAnimated:NO];
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[StopsViewController class]])
				[(StopsViewController  *)subVC reset];
			else if ([subVC isKindOfClass:[StopSearchViewController class]])
				[(StopSearchViewController  *)subVC reset];
			else if ([subVC isKindOfClass:[NearbyViewController class]])
				[(NearbyViewController *)subVC reset];
		}
	}	
}

- (void) favoriteDidChange:(id)sender
{
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[FavoriteViewController class]])
				[(FavoriteViewController  *)subVC reset];
		}
	}
}

/*
- (void) onlineUpdateRequested:(id)sender
{
	if (configController)
	{
		[configController popToRootViewControllerAnimated:NO];
		CityUpdateViewController *updateVC = [[CityUpdateViewController alloc] initWithNibName:nil bundle:nil];
		[configController pushViewController:updateVC animated:YES];
		return;
	}
	
	for (UIViewController *vc in [tabBarController viewControllers])
	{
		if ([vc isKindOfClass:[UINavigationController class]])
		{
			UIViewController *subVC = [((UINavigationController *)vc).viewControllers objectAtIndex:0];
			if ([subVC isKindOfClass:[SettingsViewController class]])
			{
				[(UINavigationController *)vc popToRootViewControllerAnimated:NO];
				[(SettingsViewController *)subVC startOnlineUpdate];
				
				
				CityUpdateViewController *updateVC = [[CityUpdateViewController alloc] initWithNibName:nil bundle:nil];
				[[self navigationController] pushViewController:updateVC animated:YES];
			}
		}
	}
}
*/


- (void) checkForUpdate
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	CityUpdateViewController *cityUpdateVC = [[CityUpdateViewController alloc] init]; 
	[cityUpdateVC checkUpdates];
	BOOL newCityDbAvailable = [cityUpdateVC updateAvaiable];
	BOOL newCityOfflineDbAvailable = [cityUpdateVC newOfflineDatabaseAvailable];
	if (newCityDbAvailable && newCityOfflineDbAvailable)
		[UIApplication sharedApplication].applicationIconBadgeNumber = 2;
	else if (newCityDbAvailable || newCityOfflineDbAvailable)
		[UIApplication sharedApplication].applicationIconBadgeNumber = 1;
	else
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;		

	[pool release];
}

@end

