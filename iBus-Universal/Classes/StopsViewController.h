//
//  StopsViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusStop;
@class BusArrival;
@class StopsViewController;
@class MapViewController;

@interface StopsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView			*stopsTableView;
	NSArray				*stopsOfInterest;
	NSMutableDictionary *stopsDictionary;
	NSMutableArray		*routesOfInterest;
}

- (NSArray *) stopsOfInterest;
- (void) setStopsOfInterest: (NSArray *)stops;

- (void) reload;
- (void) needsReload;
- (void) alertOnEmptyStopsOfInterest;

- (void) arrivalsUpdated: (NSArray *)results;
- (void) showMapOfAStop:(BusStop *)theStop;

@end
