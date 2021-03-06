//
//  ArrivalCell.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 20/09/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>

enum _Arrival_Icon_Type {
	kArrivalButtonTypeBookmark,
	kArrivalButtonTypeRemove
};

@class BusArrival;

@interface ArrivalCell : UITableViewCell
{
	id             delegate;
	UIButton       *busRoute;
	UILabel        *busSign;
	UILabel        *arrivalTime1;
	UILabel        *arrivalTime2;
	//UIButton       *favoriteButton;
	NSMutableArray *theArrivals;
	UIViewController *ownerView;
}

+ (NSInteger) height;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier owner:(UIViewController *)owner;
- (BusArrival *) firstArrival;
- (void) setArrivals: (id) arrivals;

@end
