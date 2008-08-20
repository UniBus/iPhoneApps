//
//  StopsView.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusStop;
@class BusArrival;

@interface StopCell : UITableViewCell
{
	UILabel      *stopName;
	UILabel      *stopPos;
	UILabel      *stopDir;
	UIButton     *mapButton;
	BusStop      *theStop;
}

- (void) setStop:(id) aStop;

@end

@interface ArrivalCell : UITableViewCell
{
	UILabel      *busSign;
	UILabel      *arrivalTime1;
	UILabel      *arrivalTime2;
	UIButton     *favoriteButton;
	NSMutableArray *theArrivals;
}

- (void) setArrivals: (id) arrivals;

@end


@interface StopsView : UIViewController {
	NSMutableArray        *arrivalsForStops;
	NSMutableArray        *stopsOfInterest;
	IBOutlet UITableView  *stopsTableView;
	//IBOutlet StopCell     *stopCellToCopy;
	//IBOutlet ArrivalCell  *arrivalCellToCopy;
}

@property (readwrite, assign) NSMutableArray *stopsOfInterest;

- (void) reload;

@end
