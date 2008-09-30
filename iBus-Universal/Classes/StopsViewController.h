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

@interface SavedItem : NSObject <NSCoding>
{
	BusStop *stop;
	NSMutableArray *buses;
}

@property (retain) NSMutableArray *buses;
@property (retain) BusStop *stop;

@end


enum _stop_view_type_ {
	kStopViewTypeNormal,
	kStopViewTypeToAdd,
	kStopViewTypeToDelete,
};

@interface StopsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView		*stopsTableView;
	NSMutableArray  *arrivalsForStops;
	NSArray			*stopsOfInterest;
	int				stopViewType;
	NSMutableDictionary *stopsDictionary;
	NSMutableArray *routesOfInterest;
}

//@property (readwrite, retain) NSMutableArray *stopsOfInterest;
@property int stopViewType;

- (NSArray *) stopsOfInterest;
- (void) setStopsOfInterest: (NSArray *)stops;

- (void) reload;
- (void) needsReload;
- (void) alertOnEmptyStopsOfInterest;
//This is a virtual function!!!
//- (void) filterData;
- (NSArray *) arrivalsOfOneBus: (NSArray*) arrivals ofIndex: (int)index;
- (void) arrivalsUpdated: (NSArray *)results;
- (void) showMapOfAStop:(BusStop *)theStop;
- (void) busArrivalBookmarked: (BusArrival *)theArrival;

- (void) testFunction;

@end
