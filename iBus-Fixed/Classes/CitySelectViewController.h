//
//  CitySelectViewController.h
//  CitySelect
//
//  Created by Zhenwang Yao on 19/09/08.
//  Copyright Zhenwang Yao. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitySelectViewController : UIViewController < UITableViewDataSource,  UITableViewDelegate> {
	id				delegate;     
	NSMutableArray	*localCities;
	NSMutableArray	*onlineCities;
	NSString		*currentCity;
	NSString		*currentCityId;
	NSString		*currentURL;
	NSString		*currentDatabase;
	NSInteger		checkMarkedRow;
}

@property (readonly) NSString	*currentCityId;
@property (readonly) NSString	*currentCity;
@property (readonly) NSString	*currentURL;
@property (readonly) NSString	*currentDatabase;
@property (retain) id delegate;

@end

