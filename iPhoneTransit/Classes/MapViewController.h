//
//  MapViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapViewController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView  *mapWeb;
	CGPoint lastOneFingerPos;
	double  lastTwoFingerDistance;
	int     lastNumOfTouches;
	int		numberOfTouchEventToSkip;
	BOOL    loaded;
	BOOL    memoryWarning;
	double  lastRequestedLat;
	double  lastRequestedLon;
}

- (void)mapWithURL:(NSURL *)url;
- (void)mapWithLatitude: (double)lat Longitude:(double)lon;

@end