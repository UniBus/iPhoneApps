//
//  FavoriteViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsViewController.h"

BOOL saveRouteToFavorite(NSString *routeId, NSString *dirId, NSString *headSign, NSString *routeName);
BOOL removeRouteFromFavorite(NSString *routeId, NSString *dir, NSString *headSign);
BOOL isRouteInFavorite(NSString *stopId, NSString *routeId, NSString *dirId, NSString *headSign);

@interface FavoriteViewController2 : UIViewController <UITableViewDataSource, UITableViewDelegate> 
{
	UITableView *favoriteTableView;
	NSArray *favoriteStops;
	NSArray *favoriteRoutes;
}

- (void) reset;
//- (void) needsReload;

@end
