//
//  ClosestViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> //</CLLocationManager.h>
#import "StopsViewController.h"

@interface ClosestViewController : StopsViewController <CLLocationManagerDelegate> {
	CLLocationManager *location;
	UIActivityIndicatorView *indicator;
}

@end