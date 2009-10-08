//
//  FavoriteViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsViewController.h"

NSMutableDictionary * readFavorite();
//BOOL saveToFavorite(BusArrival *anArrival);
//BOOL isInFavorite(BusArrival *anArrival);

BOOL saveToFavorite2(NSString *stopId, NSString *routeId, NSString *routeName, NSString *busSign, NSString *dir);
BOOL removeFromFavorite2(NSString *stopId, NSString *routeId, NSString *dir);
BOOL isInFavorite2(NSString *stopId, NSString *routeId, NSString *dir);

@interface FavoriteViewController : StopsViewController {
	//NSMutableDictionary *favorites;
	//NSMutableArray *routesOfInterest;
}

@end
