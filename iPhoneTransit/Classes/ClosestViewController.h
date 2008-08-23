//
//  ClosestViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> //</CLLocationManager.h>
#import "StopsView.h"

@interface ClosestViewController : StopsView <CLLocationManagerDelegate> {
	CLLocationManager *location;
}

@end
