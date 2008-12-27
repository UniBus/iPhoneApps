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

#define TIMEOUT_DOWNLOAD	60.0

const NSString *OfflineURL = @"http://zyao.servehttp.com:5144/ver1.2/offline/cache.php";	

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

void updateOfflineDbInfoInGTFS(NSString *cityId, int downloaded, NSString *downloadTime)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	NSString *sql = [NSString stringWithFormat:@"UPDATE cities SET oldbdownloaded=%d, oldbtime='%@' WHERE id='%@'",
					 downloaded, (downloadTime)?downloadTime:@"", cityId];
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

BOOL offlineDbDownloaded(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return NO;
	
	BOOL downloaded = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT oldbdownloaded FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			downloaded = (sqlite3_column_int(statement, 0) == 1);
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return downloaded;
}

NSString *offlineDbDownloadTime(NSString *cityId)
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return @"";
	
	NSString *downloadTime = @"";
	NSString *sql = [NSString stringWithFormat:@"SELECT oldbtime FROM cities WHERE id='%@'", cityId];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			if (sqlite3_column_text(statement, 0))
				downloadTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
	}	
	sqlite3_finalize(statement);
	
	sqlite3_close(database);
	return downloadTime;
}

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

#pragma mark TableView Delegate Functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kUIOffline_Cache) 
	{
		TransitApp *myApplication = (TransitApp *)[UIApplication sharedApplication];
		NSString *currentDbName = [NSString stringWithFormat:@"ol-%@", [myApplication currentDatabase]];
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
			cell.textAlignment = UITextAlignmentCenter;
			cell.font = [UIFont boldSystemFontOfSize:14];
			//cell.textColor = [UIColor blueColor];
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.text = @"Cache current city for off-line viewing";
		return cell;
	}
	else if (indexPath.section == kUIOffline_Setting)
	{
		CellWithSwitch *cell = (CellWithSwitch *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifierAtOffLineSwitchView"];
		if (cell == nil) 
		{
			cell = [[[CellWithSwitch alloc] initWithFrame:CGRectZero reuseIdentifier:@"CellIdentifierAtOffLineSwitchView"] autorelease];
			cell.textAlignment = UITextAlignmentLeft;
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
			cell.text = @"Automatic Switch";
		}
		else
		{
			cell.switchOn = alwaysOffline;
			[cell.userSwitch removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
			[cell.userSwitch addTarget:self action:@selector(alwaysOfflineTap:) forControlEvents:UIControlEventValueChanged];
			[cell.userSwitch setEnabled:(autoSwitchToOffline==NO)];
			cell.text = @"Always offline";
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

- (void)fileDownloaded:(NSString *)destinationFilename
{	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	
	if (!isValidDatabase(destinationFilename))
	{
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download data invalid!" waitUntilDone:NO];
		return;
	}
	
	NSString *offlineDbName = [NSString stringWithFormat:@"ol-%@", [myApplication currentDatabase]];
	NSString *oldOfflineDb = [[myApplication localDatabaseDir] stringByAppendingPathComponent:offlineDbName];
	NSString *downloadedOfflineDb = destinationFilename;
	
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
}

@end
