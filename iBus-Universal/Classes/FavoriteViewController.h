//
//  FavoriteViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsViewController.h"

NSMutableDictionary * readFavorite();
BOOL saveToFavorite(BusArrival *anArrival);
BOOL saveToFavorite2(NSString *stopId, NSString *routeId, NSString *busSign);
BOOL removeFromFavorite2(NSString *stopId, NSString *routeId);
BOOL isInFavorite(BusArrival *anArrival);
BOOL isInFavorite2(NSString *stopId, NSString *routeId);

@interface FavoriteViewController : StopsViewController {
	//NSMutableDictionary *favorites;
	//NSMutableArray *routesOfInterest;
}

@end
