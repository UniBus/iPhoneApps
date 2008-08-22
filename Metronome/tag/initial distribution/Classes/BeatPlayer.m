//
//  BeatPlayer.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BeatPlayer.h"

@implementation BeatPlayer

- (id) init
{
	[super init];
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	//NSString *path = [[mainBundle pathForResource:@"up" ofType:@"wav"] retain];
	
	NSURL *upbeatURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"up" ofType:@"wav"] isDirectory:NO];			
	if ( AudioServicesCreateSystemSoundID((CFURLRef)upbeatURL, &soundUpBeat) != kAudioServicesNoError)
	{
		NSLog(@"Couldn't open upbeat.wav");
		[self release];
		return nil;
	}
	
	NSURL *downbeatURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"down" ofType:@"wav"] isDirectory:NO];	
	if ( AudioServicesCreateSystemSoundID((CFURLRef)downbeatURL, &soundDownBeat) != kAudioServicesNoError )
	{
		NSLog(@"Couldn't open downbeat.wav");
		[self release];
		return nil;
	}
	
	return self;
}
									  
- (void) dealloc
{
	AudioServicesDisposeSystemSoundID(soundUpBeat);
	AudioServicesDisposeSystemSoundID(soundDownBeat);
	[super dealloc];
}

- (void) playUpBeat
{
	AudioServicesPlaySystemSound(soundUpBeat);
}

- (void) playDownBeat
{
	AudioServicesPlaySystemSound(soundDownBeat);
}

@end
