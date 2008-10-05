//
//  CitySelectViewController.h
//  CitySelect
//
//  Created by Zhenwang Yao on 19/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitySelectViewController : UIViewController < UITableViewDataSource,  UITableViewDelegate> {
	id			delegate;     
	NSArray		*supportedCities;
	NSString	*currentCity;
	NSString	*currentURL;
	NSString	*currentDatabase;
}

@property (readonly) NSString *currentCity;
@property (readonly) NSString *currentURL;
@property (readonly) NSString *currentDatabase;
@property (retain) id delegate;

@end

