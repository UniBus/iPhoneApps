//
//  MapViewController.h
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 27/08/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapViewController : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView  *mapWeb;
	CGPoint lastOneFingerPos;
	double  lastTwoFingerDistance;
	int     lastNumOfTouches;
	int		numberOfTouchEventToSkip;
}

- (void)mapWithURL:(NSURL *)url;

@end
