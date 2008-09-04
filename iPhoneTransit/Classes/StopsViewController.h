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
	//int stopId;
	BusStop *stop;
	NSMutableArray *buses;
}

@property (retain) NSMutableArray *buses;
@property (retain) BusStop *stop;

@end

@interface StopCell : UITableViewCell
{
	UILabel      *stopName;
	UILabel      *stopPos;
	UILabel      *stopDir;
	UIButton     *mapButton;
	BusStop      *theStop;
	UIViewController *ownerView;
}

- (void) setStop:(id) aStop;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier owner:(UIViewController *)owner;

@end

@interface ArrivalCell : UITableViewCell
{
	UILabel        *busSign;
	UILabel        *arrivalTime1;
	UILabel        *arrivalTime2;
	UIButton       *favoriteButton;
	NSMutableArray *theArrivals;
	int            viewType;
	UIViewController *ownerView;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier viewType:(int)type owner:(UIViewController *)owner;
- (void) setArrivals: (id) arrivals;

@end

enum _stop_view_type_ {
	kStopViewTypeNormal,
	kStopViewTypeToAdd,
	kStopViewTypeToDelete,
};

@interface StopsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	IBOutlet UITableView  *stopsTableView;
	NSMutableArray        *arrivalsForStops;
	NSMutableArray        *stopsOfInterest;
	//MapViewController     *mapViewController;
	//IBOutlet StopCell     *stopCellToCopy;
	//IBOutlet ArrivalCell  *arrivalCellToCopy;
	int stopViewType;
}

@property (readwrite, retain) NSMutableArray *stopsOfInterest;
@property int stopViewType;

- (void) reload;
- (void) needsReload;
- (void) alertOnEmptyStopsOfInterest;
//This is a virtual function!!!
//- (void) filterData;
- (NSArray *) arrivalsOfOneBus: (NSArray*) arrivals ofIndex: (int)index;
- (void) showMapOfAStop:(BusStop *)theStop;

@end
