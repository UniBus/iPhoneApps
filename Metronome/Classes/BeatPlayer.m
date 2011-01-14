//
//  BeatPlayer.m
//  Metronome
//
//  Created by Zhenwang Yao on 09/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioFileStream.h>
#import "BeatPlayer.h"
#import "AudioPlayer.h"

@implementation BeatPlayer
		
@synthesize volume;

- (id) init
{
	self = [super init];
	volume = 1.0;
	return self;
}

- (void) dealloc
{
	[upbeatPlayer release];
	[downbeatPlayer release];
	[super dealloc];
}

- (void) setBeatSoundDown:(NSString *)downName andUp:(NSString *)upName
{
	[downbeatURL release];
	[upbeatURL release];

	NSBundle *mainBundle = [NSBundle mainBundle];
	downbeatURL = [[NSURL fileURLWithPath:[mainBundle pathForResource:downName ofType:@"wav"] isDirectory:NO] retain];
	upbeatURL = [[NSURL fileURLWithPath:[mainBundle pathForResource:upName ofType:@"wav"] isDirectory:NO] retain];			
	
	[upbeatPlayer release];
	upbeatPlayer = nil;
	[downbeatPlayer release];
	downbeatPlayer = nil;
}

- (void) setVolume: (float) userVolume
{
	volume = userVolume;
	if (upbeatPlayer)
		[upbeatPlayer setVolume:volume];
	if (downbeatPlayer)
		[downbeatPlayer setVolume:volume];
}

- (void) playUpBeat
{
	if (upbeatPlayer == nil)
	{
		upbeatPlayer = [[AudioPlayer alloc] initWithURL:upbeatURL];
		[upbeatPlayer setVolume:self.volume];
		
		if (!upbeatPlayer)
			NSLog(@"Fail creating upbeat player");
	}
	//[upbeatPlayer reset];
	[upbeatPlayer play];
}

- (void) playDownBeat
{

	if (downbeatPlayer == nil)
	{
		downbeatPlayer = [[AudioPlayer alloc] initWithURL:downbeatURL];
	
		[downbeatPlayer setVolume:self.volume];
		if (!downbeatPlayer)
			NSLog(@"Fail creating downbeat player");	
	}
	//[downbeatPlayer reset];
	[downbeatPlayer play];
	
}


@end
