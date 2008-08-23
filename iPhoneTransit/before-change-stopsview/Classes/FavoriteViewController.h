//
//  FavoriteViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 20/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsViewController.h"

@interface FavoriteViewController : StopsViewController {
	NSMutableArray *busesOfInterest;
}

@end
