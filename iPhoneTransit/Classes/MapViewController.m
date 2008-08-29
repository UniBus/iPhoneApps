//
//  MapViewController.m
//  iPhoneTransit
//
//  Created by Zhenwang Yao on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

#define NUM_TOUCH_SKIP		5
#define DIST_THRESHOLD_MOVE	20
#define DIST_THRESHOLD_ZOOM 20

double DistanceBetween(CGPoint point1, CGPoint point2)
{
	double value = (point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y)*(point1.y-point2.y);
	return sqrt(value);
}

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		// Initialization code
	}
	return self;
}

- (void) loadView
{
	[super loadView];
	
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.autoresizesSubviews = YES;
	self.view.multipleTouchEnabled = YES;
	
	if (mapWeb == nil)
	{
		mapWeb = [[UIWebView alloc] initWithFrame:self.view.bounds];
		mapWeb.userInteractionEnabled = NO;
		mapWeb.multipleTouchEnabled = NO;
	}

	[self.view addSubview:mapWeb];
	
	//[self becomeFirstResponder];
	//self.view = mapWeb;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void) dealloc
{
	[mapWeb release];
	[super dealloc];
}

- (void)mapWithURL:(NSURL *)url
{	
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:20];  // 20 sec;
	[mapWeb loadRequest:request];
}

- (void)mapWithLatitude: (double)lat Longitude:(double)lon
{
	//NSString *urlString = [NSString stringWithFormat:@"http://www.wenear.com/iphone-test?width=%f&height=%f", 
	//					   self.view.frame.size.width, self.view.frame.size.height];
	NSString *urlString = [NSString stringWithFormat:@"http://zhenwang.yao.googlepages.com/maplet.html?width=%f&height=%f&lat=%f&long=%f", 
						   self.view.frame.size.width, self.view.frame.size.height, lat, lon];
	
	//NSURL *url = [NSURL URLWithString:@"http://zhenwang.yao.googlepages.com/maplet.html"];
	NSURL *url= [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:20];  // 20 sec;
	[mapWeb loadRequest:request];
}

#pragma mark Map Operation

- (void) moveMapByOffset:(CGPoint)offset
{
    int centerX = ((int)[self.view bounds].size.width) >> 1;
    int centerY = ((int)[self.view bounds].size.height) >> 1;

    NSString *script = [NSString stringWithFormat:
	 @"var newCenterPixel = new GPoint(%d, %d);"
	 "var newCenterLatLng = map.fromContainerPixelToLatLng(newCenterPixel);"
	 "map.setCenter(newCenterLatLng);", 
	 (int)(centerX - offset.x), (int)(centerY - offset.y)];
	
	[mapWeb stringByEvaluatingJavaScriptFromString:script];
}

- (void) zoomMapByOffset:(double)offset
{
	int levelChange = (int) (offset/DIST_THRESHOLD_ZOOM);
	int currentLevel = [[mapWeb stringByEvaluatingJavaScriptFromString:@"map.getZoom();"] intValue];
	currentLevel += levelChange;
	if (currentLevel < 0)
		currentLevel = 0;
	else if (currentLevel > 18)
		currentLevel = 18;
	
	[mapWeb stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"map.setZoom(%d);", currentLevel]];
}

#pragma mark Multi-Touch Handlings

//-- Touch Events Handling Methods ---------------------------------------------
- (void) touchesCanceled 
{
    //[self resetTouches];
	//NSLog(@"TouchCancelled");
}
//------------------------------------------------------------------------------
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event 
{   
	numberOfTouchEventToSkip = NUM_TOUCH_SKIP;
	
	UITouch *touch0;
	UITouch *touch1;
	CGPoint touchPoint0, touchPoint1;

	touch0 = [[touches allObjects] objectAtIndex:0];
	touchPoint0 = [touch0 locationInView: self.view];
	lastOneFingerPos = touchPoint0;
	lastNumOfTouches = [touches count];
	
	if ([touches count] == 2)
	{
		touch0 = [[touches allObjects] objectAtIndex:0];
		touch1 = [[touches allObjects] objectAtIndex:1];
		touchPoint0 = [touch0 locationInView: self.view];
		touchPoint1 = [touch1 locationInView: self.view];
		lastTwoFingerDistance = DistanceBetween(touchPoint0, touchPoint1);
	}
	//NSLog(@"ToucBegin");
}
//------------------------------------------------------------------------------
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event 
{
    if (--numberOfTouchEventToSkip)
        return;
    
	numberOfTouchEventToSkip = NUM_TOUCH_SKIP;
	
	BOOL  isZooming = NO;
	UITouch *touch0;
	UITouch *touch1;
	CGPoint touchPoint0, touchPoint1;
	
	touch0 = [[touches allObjects] objectAtIndex:0];
	touchPoint0 = [touch0 locationInView:self.view];
	
	if ([touches count] == 2)
	{
		touch1 = [[touches allObjects] objectAtIndex:1];
		touchPoint1 = [touch1 locationInView: self.view];
		double twoFingerDistance = DistanceBetween(touchPoint0, touchPoint1);
		if (lastNumOfTouches == 2)
		{
			if (abs(twoFingerDistance-lastTwoFingerDistance) > DIST_THRESHOLD_ZOOM)
			{
				[self zoomMapByOffset: (twoFingerDistance-lastTwoFingerDistance)];
				lastTwoFingerDistance = twoFingerDistance;
				isZooming = YES;
			}
		}
		else
		{
			lastTwoFingerDistance = twoFingerDistance;
		}
	}

	if (!isZooming)
	{
		if (DistanceBetween(lastOneFingerPos, touchPoint0) > DIST_THRESHOLD_MOVE)
		{
			CGPoint offset = CGPointMake(touchPoint0.x-lastOneFingerPos.x, touchPoint0.y-lastOneFingerPos.y);
			lastOneFingerPos = touchPoint0;
			[self moveMapByOffset: offset];
		}
	}
	else
	{
		lastOneFingerPos = touchPoint0;
	}
	
	lastNumOfTouches = [touches count];
	
	//NSLog(@"Touch Moved");
}
//------------------------------------------------------------------------------
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2)
	{
		[self zoomMapByOffset: DIST_THRESHOLD_ZOOM];
	}
}



@end
