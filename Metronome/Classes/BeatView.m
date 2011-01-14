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

	//For some reason this init function never gets called.
	//upbeatImage = [UIImage imageNamed:@"upbeat.png"];
	//downbeatImage = [UIImage imageNamed:@"downbeat.png"];
	
	return self;
}

- (void) setUpbeatImage:(UIImage *) up
{
	[upbeatImage release];
	upbeatImage = [up retain];
	
	[self setNeedsDisplay];
}

- (void) setDownbeatImage:(UIImage *) down
{
	[downbeatImage release];
	downbeatImage = [down retain];
	
	[self setNeedsDisplay];
}

- (void)drawABeat:(UIImage *)beat inRect:(CGRect)rect highlighted:(BOOL)highlighted
{
	if (highlighted)
		[beat drawInRect:rect];
	else
		[beat drawInRect:rect blendMode:kCGBlendModeNormal alpha: 0.3];
}

- (void)drawRect:(CGRect)rect {
	if (leds == nil)
		return;
	
	if ([leds count] == 0)
		return;
		
	NSData *data = [leds objectAtIndex:0];
	CGRect *circleRect = (CGRect *) [data bytes];
	[self drawABeat:downbeatImage inRect:*circleRect highlighted:((currentBeat == 0) && (playing))];
	
	for (int i=1; i<totalBeat; i++)	{
		circleRect = (CGRect *)[[leds objectAtIndex:i] bytes];
		[self drawABeat:upbeatImage inRect:*circleRect highlighted:((currentBeat == i) && (playing))];
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
	
	totalBeat = total;

	/*
	CGFloat yPos = bound.size.height/2.; 
	CGFloat xDelta = bound.size.width/(total+1);
	
	for (int i=0; i<total; i++)
	{
		CGRect circlerect;
		circlerect.origin.x = xDelta*(i+1)-CIRCLE_RAD;
		circlerect.origin.y = yPos-CIRCLE_RAD;
		circlerect.size.width = CIRCLE_RAD*2;
		circlerect.size.height = CIRCLE_RAD*2;
	
		[leds addObject:[NSData dataWithBytes:&circlerect length:sizeof(circlerect)]];
	}
	 */
	
	CGFloat w = bound.size.width;
	CGFloat h = bound.size.height;
	
	CGFloat theta = atan2(w, h);
	CGFloat radius = sqrt(h*h+w*w)/4/cos(theta);
	CGFloat cx = w/2;
	CGFloat cy = h/4 + radius;
	CGFloat alpha = 4 * (3.1415926/2 - theta);
	
	CGFloat deltaAlpha = alpha / (total+1);
	CGFloat alpha0 = atan2(3*h/4-cy, -w/2);
	
	NSLog(@"deltaApha=%f, alpha0=%f, alpha=%f", deltaAlpha, alpha0, alpha);
	
	for (int i=0; i<total; i++)
	{
		CGRect circlerect;
		CGFloat alpha_i = alpha0 + (i+1)*deltaAlpha;
		circlerect.origin.x = radius * cos(alpha_i) + cx;
		circlerect.origin.y = radius * sin(alpha_i) + cy;
		
		circlerect.size.width = CIRCLE_RAD*2;
		circlerect.size.height = CIRCLE_RAD*2;
		
		[leds addObject:[NSData dataWithBytes:&circlerect length:sizeof(circlerect)]];
		NSLog(@"Coordinate: [%f, %f]", circlerect.origin.x, circlerect.origin.y);
	}
	
	[self setNeedsDisplay];
}

- (void)dealloc {
	[upbeatImage release];
	[downbeatImage release];
	[leds release];
	[super dealloc];
}

@end
