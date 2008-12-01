//
//  DownloadManager.h
//  iBus-Universal
//
//  Created by Zhenwang Yao on 28/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadManager : NSObject <UIActionSheetDelegate> {
	NSURLResponse	*downloadResponse;
	NSURLConnection	*theDownload;
	NSMutableData	*receivedData;
	UIActionSheet	*downloadActionSheet;
	NSInteger		bytesReceived;
	NSInteger		downloadState;
	
	id				delegate;
	UIView			*hostView;
	NSString		*localFileName;
}

@property (retain) id delegate;
@property (retain) UIView *hostView;

- (void) downloadURL:(NSString *) urlString asFile:(NSString *) fileName;

@end
