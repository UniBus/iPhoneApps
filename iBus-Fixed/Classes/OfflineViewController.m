//
//  CityUpdateViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//

#import "OfflineViewController.h"
#import "TransitApp.h"
#import "MiscCells.h"
#import "Upgrade.h"
//#import "Compression.h"
#import <zlib.h>
#define CHUNK 16384	//16K

#define TIMEOUT_DOWNLOAD	60.0

const NSString *OfflineURL = @"http://zyao.servehttp.com:5144/ver1.4/offline/cache.php";	

BOOL autoSwitchToOffline = NO;
BOOL alwaysOffline = NO;

extern BOOL  offlineUpdateAvailable;
extern BOOL  offlineDownloaded;

enum OfflineViewSections
{
	kUIOffline_Cache = 0,
	kUIOffline_Setting,
	kUIOffline_Section_Num
};

@interface OfflineViewController (private)
- (void)startDownloadingURL:(NSString *) urlString asFile:(NSString *) fileName;
@end


@implementation OfflineViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	autoSwitchToOffline = [defaults boolForKey:UserSavedAutoSwitchOffline];
	alwaysOffline = [defaults boolForKey:UserSavedAlwayOffline];	
	
	 offlineTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped]; 
	[offlineTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	offlineTableView.delegate = self;
	offlineTableView.dataSource = self;
	self.view = offlineTableView; 
	
	self.navigationItem.title = @"Offline";	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
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

- (void)dealloc 
{
	[offlineTableView release];
	[downloader release];
	[super dealloc];
}

- (void) updateSwitchEnabled
{
	//Disable alwayOff setting
	CellWithSwitch *cellToUpdate = (CellWithSwitch *) [offlineTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: 1 inSection:kUIOffline_Setting]];
	if ([cellToUpdate isKindOfClass:[CellWithSwitch class]])
	{
		[cellToUpdate.userSwitch setEnabled:(autoSwitchToOffline==NO)];
	}
	else
		NSAssert(NO, @"Didn't get the right row, check the indexPath");
}

- (IBAction) automaticSwitchTap:(id)sender
{
	autoSwitchToOffline = ((UISwitch *)sender).on;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setFloat:autoSwitchToOffline forKey:UserSavedAutoSwitchOffline];
	[self updateSwitchEnabled];
}

- (IBAction) alwaysOfflineTap:(id)sender
{
	alwaysOffline = ((UISwitch *)sender).on;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setFloat:alwaysOffline forKey:UserSavedAlwayOffline];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)theButtonIndex
{
	unzippingCancelled = YES;
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:applicationTitle
													message:@"Installing in progress, please wait"
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];	
	[alert release];
	 */
}

#pragma mark TableView Delegate Functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kUIOffline_Cache) 
	{
		TransitApp *myApplication = (TransitApp *)[UIApplication sharedApplication];
		NSString *currentDbName = [NSString stringWithFormat:@"ol-%@.zip", [myApplication currentDatabase]];
		NSString *urlString = [NSString stringWithFormat:@"%@?%@", OfflineURL, [myApplication currentCityId]];
		
		[self startDownloadingURL:urlString asFile:currentDbName];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	return;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kUIOffline_Section_Num;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == kUIOffline_Cache) 
	{
		return @"Offline Viewing?";
	}
	else if (section == kUIOffline_Setting)
	{
		return @"Setting for Offline Viewing";
	}
	
	NSAssert(NO, @"Something is wrong!!");
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == kUIOffline_Cache) 
		return 1;
	else if (section == kUIOffline_Setting)
		return 2;

	NSAssert(NO, @"Something is wrong!!");
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.section == kUIOffline_Cache) 
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtOffLineCell"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CellIdentifierAtOffLineCell"] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			//cell.textColor = [UIColor blueColor];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textLabel.text = @"Cache current city for off-line viewing";
		return cell;
	}
	else if (indexPath.section == kUIOffline_Setting)
	{
		CellWithSwitch *cell = (CellWithSwitch *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtOffLineSwitchView"];
		if (cell == nil) 
		{
			cell = [[[CellWithSwitch alloc] initWithFrame:CGRectMake(0, 0, REGULARCELL_WIDTH, SLIDERCELL_HEIGHT) reuseIdentifier:@"CellIdentifierAtOffLineSwitchView"] autorelease];
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//cell.font = [UIFont systemFontOfSize:14];
			//cell.textColor = [UIColor blueColor];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 0)
		{
			cell.switchOn = autoSwitchToOffline;
			[cell.userSwitch removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
			[cell.userSwitch addTarget:self action:@selector(automaticSwitchTap:) forControlEvents:UIControlEventValueChanged];
			cell.label.text = @"Automatic switch";
		}
		else
		{
			cell.switchOn = alwaysOffline;
			[cell.userSwitch removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
			[cell.userSwitch addTarget:self action:@selector(alwaysOfflineTap:) forControlEvents:UIControlEventValueChanged];
			[cell.userSwitch setEnabled:(autoSwitchToOffline==NO)];
			cell.label.text = @"Always offline";
		}
		return cell;
	}
	
	NSAssert(NO, @"Something is wrong!!");	
	return nil;
}

#pragma mark DownloadManager related function.
- (void)startDownloadingURL:(NSString *) urlString asFile:(NSString *) fileName
{
	if (downloader == nil)
	{
		downloader = [[DownloadManager alloc] init];
		downloader.delegate = self;
		downloader.hostView = self.view;
	}
	[downloader downloadURL:urlString asFile:fileName];
}

- (void) unzipingStatusUpdateSizeReceived:(NSNumber *)size
{
	totalSize = [size intValue] * 5;  
	/* This is a very rough estimation, 
	 * since zlib couldnt provide the size of orginal file.
	 */
}

- (void) unzipingStatusUpdateChunkUnzipped:(NSNumber *)size
{
	int receivedSize = [size intValue];
	if (totalSize == 0)
	{
		[unzipActionSheet setTitle:[NSString stringWithFormat:@"Installing %d (KBytes)", receivedSize/1024]];
	}
	else
	{
		float percentComplete = 0;
		if (receivedSize > totalSize)
			percentComplete = 100.;
		else
			percentComplete=(receivedSize/(float)totalSize)*100.0;
		[unzipActionSheet setTitle:[NSString stringWithFormat:@"Installing %.1f %%", percentComplete]];
	}
}

- (void) unzipingStatusUpdateFinished
{
	[unzipActionSheet setTitle:@"Installing Done"];
}

- (void) unzipFile:(NSString *)sourcePath
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if([fileManager fileExistsAtPath:sourcePath]){
		NSDictionary * attributes = [fileManager attributesOfItemAtPath:sourcePath error:&error];
		// file size
		NSNumber *theFileSize;
		if (theFileSize = [attributes objectForKey:NSFileSize])
		{
			[self performSelectorOnMainThread:@selector(unzipingStatusUpdateSizeReceived:) withObject:theFileSize waitUntilDone:NO];
			//[self performSelector:@selector(unzipingStatusUpdateSizeReceived:) withObject:theFileSize];
		}
	}
	else
		NSAssert(NO, @"Downloaded filed doesn't exist!");		
	
	NSString *destPath = [[sourcePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tmp.sqlite"];
	gzFile file = gzopen([sourcePath UTF8String], "rb");
	FILE *dest = fopen([destPath UTF8String], "w");
	if ( (file == NULL) || (dest == NULL) )
	{
		[pool release];
		return;
	}
	
	BOOL faulty = NO;
	unsigned char buffer[CHUNK];
	int uncompressedLength;
	int totalLength = 0;
	while (uncompressedLength = gzread(file, buffer, CHUNK) ) {
		// got data out of our file
		if(fwrite(buffer, 1, uncompressedLength, dest) != uncompressedLength || ferror(dest)) {
			NSLog(@"Error unzipping data");
			faulty = YES;
			break;
		}
		//[NSThread sleepForTimeInterval:0.01];
		if (unzippingCancelled)
		{
			faulty = YES;
			break;
		}
		totalLength += uncompressedLength;
		[self performSelectorOnMainThread:@selector(unzipingStatusUpdateChunkUnzipped:) withObject:[NSNumber numberWithInt:totalLength] waitUntilDone:NO];
		//[self performSelector:@selector(unzipingStatusUpdateChunkUnzipped:) withObject:[NSNumber numberWithInt:totalLength]];
	}
	
	[self performSelectorOnMainThread:@selector(unzipingStatusUpdateFinished) withObject:nil waitUntilDone:NO];
	
	fclose(dest);
	gzclose(file);

	if (!faulty)
		[self performSelectorOnMainThread:@selector(fileUnzipped:) withObject:destPath waitUntilDone:NO];
		//[self performSelector:@selector(fileUnzipped:) withObject:destPath];
		
	//Remove the downloaded zip file
	if (![fileManager removeItemAtPath:sourcePath error:&error])
	{
		NSAssert1(NO, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
	}
	else
		NSLog(@"Delete file: %@", sourcePath);
	
	[pool release];
}

- (void)fileDownloaded:(NSString *)destinationFilename
{	
	unzippingCancelled = NO;
	[self performSelectorInBackground:@selector(unzipFile:) withObject:destinationFilename];
	// open a dialog with an OK and cancel button
	unzipActionSheet = [[UIActionSheet alloc] initWithTitle:@"Installing (0.0 %)"
												   delegate:self
										  cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:nil 
										  otherButtonTitles:nil];
	unzipActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[unzipActionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[unzipActionSheet release];	
	
}

- (void) fileUnzipped:(NSString *)downloadedOfflineDb
{		
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	NSString *offlineDbName = [NSString stringWithFormat:@"ol-%@", [myApplication currentDatabase]];
	NSString *oldOfflineDb = [[myApplication localDatabaseDir] stringByAppendingPathComponent:offlineDbName];
	//NSString *downloadedOfflineDbZipped = destinationFilename;	
	//NSString *downloadedOfflineDb = [[downloadedOfflineDbZipped stringByDeletingLastPathComponent] stringByAppendingPathComponent:offlineDbName];
	
	/*
	if (!UnzipFile(downloadedOfflineDbZipped, downloadedOfflineDb))
	{		
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download file invalid!" waitUntilDone:NO];
		return;
	}
	 */
	
	if (!isValidDatabase(downloadedOfflineDb))
	{
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download database invalid!" waitUntilDone:NO];
		return;
	}
	
	//Copy database file to local directory.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if ([fileManager fileExistsAtPath:oldOfflineDb])
	{
		if (![fileManager removeItemAtPath:oldOfflineDb error:&error])
		{
			NSAssert1(NO, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
			return;
		}
		NSLog(@"Delete file: %@", oldOfflineDb);
	}
	
	if (![fileManager moveItemAtPath:downloadedOfflineDb toPath:oldOfflineDb error:&error])	
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return;
	}	
	NSLog(@"Move database from %@", downloadedOfflineDb);
	
	//Update database
	NSString *currentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *downloadTime = [formatter stringFromDate:[NSDate date]];
	updateOfflineDbInfoInGTFS(currentCityId, 1, downloadTime);
	
	offlineUpdateAvailable = NO;
	offlineDownloaded = YES;
	
	[unzipActionSheet  dismissWithClickedButtonIndex:-1 animated:NO];
}

/*
- (void)fileDownloaded:(NSString *)destinationFilename
{	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	NSString *offlineDbName = [NSString stringWithFormat:@"ol-%@", [myApplication currentDatabase]];
	NSString *oldOfflineDb = [[myApplication localDatabaseDir] stringByAppendingPathComponent:offlineDbName];
	NSString *downloadedOfflineDbZipped = destinationFilename;	
	NSString *downloadedOfflineDb = [[downloadedOfflineDbZipped stringByDeletingLastPathComponent] stringByAppendingPathComponent:offlineDbName];
		
	if (!UnzipFile(downloadedOfflineDbZipped, downloadedOfflineDb))
	{		
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download file invalid!" waitUntilDone:NO];
		return;
	}
		
	if (!isValidDatabase(downloadedOfflineDb))
	{
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download database invalid!" waitUntilDone:NO];
		return;
	}
	
	//Copy database file to local directory.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if (![fileManager removeItemAtPath:downloadedOfflineDbZipped error:&error])
	{
		NSAssert1(NO, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
	}
	else
		NSLog(@"Delete file: %@", oldOfflineDb);

	
	if ([fileManager fileExistsAtPath:oldOfflineDb])
	{
		if (![fileManager removeItemAtPath:oldOfflineDb error:&error])
		{
			NSAssert1(NO, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
			return;
		}
		NSLog(@"Delete file: %@", oldOfflineDb);
	}
	
	if (![fileManager moveItemAtPath:downloadedOfflineDb toPath:oldOfflineDb error:&error])	
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return;
	}	
	NSLog(@"Move database from %@", downloadedOfflineDb);
	
	//Update database
	NSString *currentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSString *downloadTime = [formatter stringFromDate:[NSDate date]];
	updateOfflineDbInfoInGTFS(currentCityId, 1, downloadTime);
	
	offlineUpdateAvailable = NO;
	offlineDownloaded = YES;
}
*/

@end
