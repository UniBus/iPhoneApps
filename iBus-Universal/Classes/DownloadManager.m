//
//  DownloadManager.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"

#define TIMEOUT_DOWNLOAD	60.0

enum DownloadState {
	kDownloadStateIdle,
	kDownloadStateSelected,
	kDownloadStateDownloading,
	kDownloadStateDownloaded
};

@implementation DownloadManager
@synthesize delegate, hostView;

- (id) init
{
	[super init];
	downloadState = kDownloadStateIdle;
	return self;
}

- (void) dealloc
{
	[downloadResponse release];
	[super dealloc];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)theButtonIndex
{
	NSAssert(downloadState == kDownloadStateDownloading, @"Downloader in a wrong state!!");	
	
	if (downloadState == kDownloadStateDownloading)
	{
		[theDownload cancel];
		downloadState = kDownloadStateIdle;
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}	
}

#pragma mark Download Manager
- (void)startDownloadingURL:(NSString *) urlString
{	
	// create the request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:TIMEOUT_DOWNLOAD];
	// create the connection with the request
	// and start loading the data
	theDownload=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (!theDownload) {
		NSLog(@"Fail to initiate download!!");
		return;
	}
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	downloadState = kDownloadStateDownloading;	
	if (hostView)
	{
		// open a dialog with an OK and cancel button
		downloadActionSheet = [[UIActionSheet alloc] initWithTitle:@"Downloading (0.0 %)"
														  delegate:self
												 cancelButtonTitle:@"Cancel" 
											destructiveButtonTitle:nil 
												 otherButtonTitles:nil];
		downloadActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[downloadActionSheet showInView:hostView]; // show from our table view (pops up in the middle of the table)
		[downloadActionSheet release];	
	}
	
	receivedData=[[NSMutableData data] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	
	bytesReceived=0;
    [receivedData setLength:0];
	
	[downloadResponse release];
	downloadResponse = [response retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
	
	long expectedLength=[downloadResponse expectedContentLength];
	
	bytesReceived=bytesReceived+[data length];
	
	if (expectedLength != NSURLResponseUnknownLength) {
		// if the expected content length is
		// available, display percent complete
		float percentComplete=(bytesReceived/(float)expectedLength)*100.0;
		[downloadActionSheet setTitle:[NSString stringWithFormat:@"Downloading %.1f %%", percentComplete]];
		//NSLog(@"Percent complete - %f",percentComplete);
	} else {
		// if the expected content length is
		// unknown just log the progress
		[downloadActionSheet setTitle:[NSString stringWithFormat:@"Downloading (%d) bytes", bytesReceived]];
		//NSLog(@"Bytes received - %d",bytesReceived);
	}	
}

- (void)connection:(NSURLConnection *)download  didFailWithError:(NSError *)error
{
	// release the connection
	[download release];
    [receivedData release];
	download = nil;
	receivedData = nil;
	[downloadActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	downloadState = kDownloadStateIdle;
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	// inform the user
	[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download failed!" waitUntilDone:NO];
	NSLog(@"Download failed! Error - %@ %@",
		  [error localizedDescription],
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)download
{
	// release the connection
	[download release];
	download = nil;
	[downloadActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	
	//Create $HOME/Download if the directory does not exist.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *homeDirectory = [paths objectAtIndex:0];	
	NSString *downloadPath = [homeDirectory stringByAppendingPathComponent:@"Downloads"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if (![fileManager fileExistsAtPath:downloadPath])
	{
		if ([fileManager createDirectoryAtPath:downloadPath attributes:nil])
			NSLog(@"Create path: %@", downloadPath);
		else
			NSLog(@"Failed to create path: %@", downloadPath);
	}
	
	//Create the downloaded file
	NSString *destinationFilename=[downloadPath stringByAppendingPathComponent:localFileName];
	if ([fileManager fileExistsAtPath:destinationFilename])
	{
		if (![fileManager removeItemAtPath:destinationFilename error:&error])
		{
			NSAssert1(0, @"Failed to delete database file with message '%@'.", [error localizedDescription]);
			return;
		}
	}
	BOOL dataWritten = [receivedData writeToFile:destinationFilename options:NSAtomicWrite error:&error];
	[receivedData release];
	receivedData = nil;
	if (!dataWritten)
	{
		NSLog(@"Failed write downloaded data into file with message '%@'.", [error localizedDescription]);
		return;
	}
	
	// do something with the data
	NSLog(@"%@",@"download succeeded!");
	downloadState = kDownloadStateDownloaded;
	
	@try 
	{
		[delegate performSelector:@selector(fileDownloaded:) withObject: destinationFilename];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Failed to call fileDownload: delegate function!");
	}
	
	downloadState = kDownloadStateIdle;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark Download Interface
- (void) downloadURL:(NSString *) urlString asFile:(NSString *) fileName
{
	NSAssert(downloadState==kDownloadStateIdle, @"Having finish previous download!");
	localFileName = fileName;
	[self startDownloadingURL:urlString];
}

@end
