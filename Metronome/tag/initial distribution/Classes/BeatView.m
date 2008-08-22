//
//  BeatView.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <ApplicationServices/ApplicationServices.h>
#import "BeatView.h"

#define CIRCLE_RAD		10

@implementation BeatView

@synthesize totalBeat, currentBeat, playing;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	
	return self;
}

- (void)drawALed:(CGContextRef)context inRect:(CGRect)rect
{
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, rect);
	CGContextClosePath(context);
	CGContextFillPath(context);	
}

- (void)drawRect:(CGRect)rect {
	if (leds == nil)
		return;
	
	if ([leds count] == 0)
		return;
	
	CGContextRef context;
	context = UIGraphicsGetCurrentContext();

	if ((currentBeat == 0) && (playing))
		[[UIColor redColor] set];
	else
		[[[UIColor redColor] colorWithAlphaComponent:0.3] set];
		
	NSData *data = [leds objectAtIndex:0];
	CGRect *circleRect = (CGRect *) [data bytes];
	[self drawALed:context inRect:*circleRect];
	
	for (int i=1; i<totalBeat; i++)	{
		if ((currentBeat == i) && playing)
			[[UIColor greenColor] set];	
		else
			[[[UIColor greenColor] colorWithAlphaComponent:0.3] set];	
		circleRect = (CGRect *)[[leds objectAtIndex:i] bytes];
		[self drawALed:context inRect:*circleRect];
	}
}

- (void) setCurrentBeat:(NSInteger) current
{
	if (currentBeat == current)
		return;
	
	currentBeat = current;
	[self setNeedsDisplay];
}

- (void) setPlaying:(BOOL) b
{
	if (playing == b)
		return;
	playing = b;
	[self setNeedsDisplay];
}

- (void) setTotalBeat:(NSInteger) total
{
	if (leds == nil)
	{
		leds = [[NSMutableArray alloc] init];
	}	
	[leds removeAllObjects];
	
	CGRect bound = [self bounds];
	//NSRect bounds = [self bounds];
	
	totalBeat = total;

	CGFloat yPos = bound.size.height/2.; 
	CGFloat xDelta = bound.size.width/(total+1);
	
	//CGContext *context;
	//context = UIGraphicsGetCurrentContext();
	for (int i=0; i<total; i++)
	{
		CGRect circlerect;
		circlerect.origin.x = xDelta*(i+1)-CIRCLE_RAD;
		circlerect.origin.y = yPos-CIRCLE_RAD;
		circlerect.size.width = CIRCLE_RAD*2;
		circlerect.size.height = CIRCLE_RAD*2;
	
		//NSData *data;
		//data = [NSData dataWithBytes:&circlerect length:sizeof(circlerect)];		
		[leds addObject:[NSData dataWithBytes:&circlerect length:sizeof(circlerect)]];
	}
	
	[self setNeedsDisplay];
}

- (void)dealloc {
	[leds release];
	[super dealloc];
}

@end
