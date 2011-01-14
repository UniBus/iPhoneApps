//
//  TripMapViewController.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 27/11/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface TripMapViewController : MapViewController {

}

- (void)mapWithTrip: (NSString *)tripId;

@end
