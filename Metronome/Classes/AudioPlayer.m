/*
File: AudioPlayer.m
Abstract: The playback class for SpeakHere, which in turn employs 
a playback audio queue object from Audio Queue Services.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/


#include <AudioToolbox/AudioToolbox.h>
#import "AudioPlayer.h"

static void playbackCallback (void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef bufferReference) 
{
}

@interface AudioPlayer (private)
- (void) openPlaybackFile: (CFURLRef) fileURL;
- (void) setupPlaybackAudioQueueObject;
- (void) setupAudioQueueBuffers;
- (void) calculateSizesFor: (Float64) seconds;
@end

@implementation AudioPlayer

- (id) initWithURL: (CFURLRef) soundFile 
{
	self = [super init];

	if (self != nil) {

		audioFileURL = soundFile;
		[self openPlaybackFile: audioFileURL];
		[self setupPlaybackAudioQueueObject];
		[self setupAudioQueueBuffers];
	}

	return self;
} 

- (void) openPlaybackFile: (CFURLRef) soundFile 
{
	AudioFileOpenURL (
		audioFileURL,
		0x01, //fsRdPerm,						// read only
		kAudioFileCAFType,
		&audioFileID
	);

	UInt32 sizeOfPlaybackFormatASBDStruct = sizeof (audioFormat);
	
	// get the AudioStreamBasicDescription format for the playback file
	AudioFileGetProperty (
	
		audioFileID, 
		kAudioFilePropertyDataFormat,
		&sizeOfPlaybackFormatASBDStruct,
		&audioFormat
	);
}

- (void) setupPlaybackAudioQueueObject 
{
	// create the playback audio queue object
	AudioQueueNewOutput (
		&audioFormat,
		playbackCallback,
		self, 
		CFRunLoopGetCurrent (),
		kCFRunLoopCommonModes,
		0,								// run loop flags
		&queueObject
	);
}

- (void) setVolume:(float)volume
{	
	AudioQueueSetParameter (queueObject, kAudioQueueParam_Volume, volume);	
}

- (void) setupAudioQueueBuffers 
{	
	[self calculateSizesFor: (Float64) kSecondsPerBuffer];
	
	AudioQueueAllocateBuffer (
							  queueObject,
							  bufferByteSize,
							  &buffers[0]
							  );
	
	UInt32 numBytes;
	UInt32 numPackets = numPacketsToRead;
	// This callback is called when the playback audio queue object has an audio queue buffer
	// available for filling with more data from the file being played
	AudioFileReadPackets (
							  audioFileID,
							  NO,
							  &numBytes,
							  NULL, //packetDescriptions,
							  0,
							  &numPackets, 
							  buffers[0]->mAudioData
							  );
		
	if (numPackets > 0) {
			
			buffers[0]->mAudioDataByteSize = numBytes;		
			
			AudioQueueEnqueueBuffer (
									 queueObject,
									 buffers[0],
									 0, //(packetDescriptions? numPackets : 0),
									 NULL //packetDescriptions
									 );
	} 
}

- (void) play 
{
	[self reset];
	AudioQueueStart (queueObject, NULL);			// start time. NULL means ASAP.
}

- (void) stop 
{
	AudioQueueStop (queueObject, TRUE);
}

- (void) reset 
{
	AudioQueueStop (queueObject, TRUE);
	AudioQueueEnqueueBuffer (
							 queueObject,
							 buffers[0],
							 (packetDescriptions? numPacketsToRead : 0),
							 packetDescriptions
							 );	
}


- (void) calculateSizesFor: (Float64) seconds 
{
	UInt32 maxPacketSize;
	UInt32 propertySize = sizeof (maxPacketSize);
	
	AudioFileGetProperty (
		audioFileID, 
		kAudioFilePropertyPacketSizeUpperBound,
		&propertySize,
		&maxPacketSize
	);

	static const int maxBufferSize = 0x10000;	// limit maximum size to 64K
	static const int minBufferSize = 0x5000;	// limit minimum size to 16K

	//Float64 numPacketsForTime = audioFormat.mSampleRate / audioFormat.mFramesPerPacket * seconds;
	
	if (audioFormat.mFramesPerPacket) {
		Float64 numPacketsForTime = audioFormat.mSampleRate / audioFormat.mFramesPerPacket * seconds;
		bufferByteSize = numPacketsForTime * maxPacketSize;
	} else {
		// if frames per packet is zero, then the codec doesn't know the relationship between 
		// packets and time -- so we return a default buffer size
		bufferByteSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
	}
	
		// we're going to limit our size to our default
	if (bufferByteSize > maxBufferSize && bufferByteSize > maxPacketSize) {
		bufferByteSize = maxBufferSize;
	} else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (bufferByteSize < minBufferSize) {
			bufferByteSize = minBufferSize;
		}
	}
	
	numPacketsToRead = bufferByteSize / maxPacketSize;
}

- (void) dealloc 
{
	AudioQueueDispose (queueObject, YES);
	AudioFileClose (audioFileID);
	
	[super dealloc];
}

@end
