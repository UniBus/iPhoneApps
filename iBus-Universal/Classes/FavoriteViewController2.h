//
//  FavoriteViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsViewController.h"

NSArray *readFavoriteStops();
NSArray * readFavoriteRoutes();

BOOL saveRouteToFavorite(NSString *routeId, NSString *dirId, NSString *headSign, NSString *routeName);
BOOL removeRouteFromFavorite(NSString *routeId, NSString *dir);
BOOL setRouteIndexInFavorite(NSString *routeId, NSString *dirId, NSInteger index);
BOOL isRouteInFavorite(NSString *routeId, NSString *dirId);

BOOL saveStopToFavorite(NSString *stopId);
BOOL removeStopFromFavorite(NSString *stopId);
BOOL setStopIndexInFavorite(NSString *stopId, NSInteger index);
BOOL isStopInFavorite(NSString *stopId);

@interface FavoriteViewController2 : UIViewController <UITableViewDataSource, UITableViewDelegate> 
{
	UITableView *favoriteTableView;
	NSMutableArray *favoriteStops;
	NSMutableArray *favoriteRoutes;
}

- (void) reset;
//- (void) needsReload;

@end
