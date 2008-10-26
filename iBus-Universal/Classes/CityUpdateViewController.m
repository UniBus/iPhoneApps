//
//  CityUpdateViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CityUpdateViewController.h"
#import "TransitApp.h"

#define TIMEOUT_DOWNLOAD	60.0

const NSString *GTFSUpdateURL = @"http://zyao.servehttp.com:5144/updates/";

enum CityUpdateSections
{
	kUIUpdate_CurrentCity = 0,
	kUIUpdate_NewCity,
	kUIUpdate_UpdatedCity,
	kUIUpdate_AllOtherCity,
	kUIUpdate_Section_Num
};

enum CityUpdateStatus {
	kCityDatabaseError = -1,
	kCityUnChanged = 0,
	kCityNewlyAdded,
	kCityNewlyUpdated
};

enum DownloadState {
	kDownloadStateIdle,
	kDownloadStateSelected,
	kDownloadStateDownloading,
	kDownloadStateDownloaded
};

@interface CityUpdateViewController (private)
- (NSInteger) checkCityInLocalDb: (NSString *)city lastUpdate:(NSString *)updateDate;
- (void) checkUpdates;
- (void)startDownloadingURL:(NSString *) urlString;
@end

@implementation CityUpdateViewController

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	otherCitiesFromServer = [[NSMutableArray alloc] init];
	newCitiesFromServer = [[NSMutableArray alloc] init];
	updateCitiesFromServer = [[NSMutableArray alloc] init];
	[self checkUpdates];
	[updateTableView reloadData];
	downloadState = kDownloadStateIdle;
	
	self.navigationItem.title = @"Online Update";	
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
	[newCitiesFromServer release];
	[updateCitiesFromServer release];
	[otherCitiesFromServer release];
	[downloadResponse release];
	[super dealloc];
}

#pragma mark database
- (void) addCityToLocalGTFSInfo: (GTFS_City *)aCity
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	BOOL existed = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT lastupdate FROM cities WHERE id=\"%@\"", aCity.cid];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			existed = YES;
	}	
	sqlite3_finalize(statement);
	
	if (existed)
		sql = [NSString stringWithFormat:@"UPDATE cities SET website='%@', dbname='%@', lastupdate='%@', local=1 WHERE id='%@'",
			   aCity.website, aCity.dbname, aCity.lastupdate, aCity.cid];
	else
		sql = [NSString stringWithFormat:@"INSERT INTO cities (id, name, state, country, website, dbname, lastupdate, local) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)", 
					 aCity.cid, aCity.cname, aCity.cstate, aCity.country, aCity.website, aCity.dbname, aCity.lastupdate, 1];
	
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

- (void) updateCityToLocalGTFSInfo: (GTFS_City *)aCity
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	NSString *sql = [NSString stringWithFormat:@"UPDATE cities SET website='%@', dbname='%@', lastupdate='%@', local=1 WHERE id='%@'",
					 aCity.website, aCity.dbname, aCity.lastupdate, aCity.cid];
	
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

- (NSInteger) checkCityInLocalDb:(NSString*) city lastUpdate: (NSString *)updateDate
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return kCityDatabaseError;
	
	int result = kCityUnChanged; 
	NSString *sql = [NSString stringWithFormat:@"SELECT lastupdate FROM cities WHERE id=\"%@\" AND local=1", city];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) != SQLITE_ROW)
			result = kCityNewlyAdded;
		else
		{
			NSString *lastUpdate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			if ([lastUpdate compare:updateDate] == NSOrderedAscending)
				result = kCityNewlyUpdated;
		}
	}
	else
	{
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_finalize(statement);
	sqlite3_close(database);	
	return result;
}

- (void) flagCityToLocalGTFSInfo: (GTFS_City *)aCity
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	BOOL existed = NO;
	NSString *sql = [NSString stringWithFormat:@"SELECT lastupdate FROM cities WHERE id=\"%@\"", aCity.cid];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
			existed = YES;
	}	
	sqlite3_finalize(statement);
	
	if (!existed)
	{
		sql = [NSString stringWithFormat:@"INSERT INTO cities (id, name, state, country, website, dbname, lastupdate, local) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)", 
						 aCity.cid, aCity.cname, aCity.cstate, aCity.country, aCity.website, aCity.dbname, aCity.lastupdate, 0];
	
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
			NSLog(@"Error: %s", sqlite3_errmsg(database));		
	}
	
	sqlite3_close(database);	
}

- (BOOL) copyFavoriteTableFrom:(NSString *)oldDb to:(NSString *)newDb
{
	sqlite3 *destDb;
	if (sqlite3_open([newDb UTF8String], &destDb) != SQLITE_OK) 
		return NO;

	BOOL result = YES;
	NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS src", oldDb];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorites SELECT * FROM src.favorites"];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}

	sqlite3_close(destDb);	
	return result;
}

#pragma mark XML query
- (void) checkUpdates
{
	NSString *urlString = [NSString stringWithFormat:@"%@cities.php", GTFSUpdateURL];
	NSURL *queryURL = [NSURL URLWithString:urlString];	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:queryURL];
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];

	[parser parse];

	NSError *parseError = [parser parserError];
	if (parseError) {
		NSLog(@"Error: %@", parseError);
	}

	[parser release];
	
	needUpdateForCurrentyCity = NO;
	NSString *appCurrentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];	
	for (GTFS_City *aCity in updateCitiesFromServer)
	{
		if ([aCity.cid isEqualToString:appCurrentCityId])
		{
			needUpdateForCurrentyCity = YES;
			break;
		}
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[parser abortParsing];

	[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed!" waitUntilDone:NO];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"city"]) 
	{
		GTFS_City *city = [[GTFS_City alloc] init];
		city.cid = [attributeDict valueForKey:@"id"];
		city.cname = [attributeDict valueForKey:@"name"];
		city.cstate = [attributeDict valueForKey:@"state"];
		city.country = [attributeDict valueForKey:@"country"];
		city.website = [attributeDict valueForKey:@"website"];
		city.dbname = [attributeDict valueForKey:@"dbname"];
		city.lastupdate = [attributeDict valueForKey:@"lastupdate"];
		
		NSInteger status = [self checkCityInLocalDb:city.cid lastUpdate:city.lastupdate];
		if (status == kCityNewlyAdded)
		{
			[newCitiesFromServer addObject:city];
			[self flagCityToLocalGTFSInfo:city];
		}
		else if (status == kCityNewlyUpdated)
			[updateCitiesFromServer addObject:city];
		else
			[otherCitiesFromServer addObject:city];
		[city release];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//[arrivalsForStops sortUsingSelector:@selector(compare:)];
	return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	return;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	return;
}

#pragma mark Action-Sheet
- (void) updateCityToLocal
{
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet;
	//NSString *otherButtonTitle = nil;
	if (downloadingNewCity)
		actionSheet = [[UIActionSheet alloc] initWithTitle:UserApplicationTitle
												  delegate:self
										 cancelButtonTitle:@"Cancel" 
									destructiveButtonTitle:@"OK" 
										 otherButtonTitles:nil];
	else
	{
		actionSheet = [[UIActionSheet alloc] initWithTitle:UserApplicationTitle
															 delegate:self
													cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:@"Overwrite" 
													otherButtonTitles:@"Overwrite, Keep Favorites", nil];
	}
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)theButtonIndex
{
	if (theButtonIndex == actionSheet.destructiveButtonIndex) //OK
	{
		if (downloadState == kDownloadStateSelected)
		{
			NSString *urlString = [NSString stringWithFormat:@"%@%@", GTFSUpdateURL, updatingCity.dbname];
			[self startDownloadingURL:urlString];
			downloadState = kDownloadStateDownloading;
			overwriteFavorites = YES;
		}
		else
			NSAssert(NO, @"Get an OK from ActionSheet, but don't know what to do!!");
	}
	else if (theButtonIndex == actionSheet.cancelButtonIndex) 
	{
		if (downloadState == kDownloadStateSelected)
		{
			downloadState = kDownloadStateIdle;
			updatingCity = nil;
		}
		else if (downloadState == kDownloadStateDownloading)
		{
			[theDownload cancel];
			downloadState = kDownloadStateIdle;
			updatingCity = nil;
		}	
		else
			NSAssert(NO, @"Get an CANCEL from ActionSheet, but don't know what to do!!");
	}
	else if (theButtonIndex == actionSheet.firstOtherButtonIndex) 
	{
		if (downloadState == kDownloadStateSelected)
		{
			NSString *urlString = [NSString stringWithFormat:@"%@%@", GTFSUpdateURL, updatingCity.dbname];
			[self startDownloadingURL:urlString];
			downloadState = kDownloadStateDownloading;
			overwriteFavorites = NO;
		}
		else
			NSAssert(NO, @"Get an OtherButton from ActionSheet, but don't know what to do!!");
	}
	else
	{
		NSAssert(NO, @"Wrong buttonIndex on actionSheet!!");
	}
	
}

#pragma mark TableView Delegate Functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kUIUpdate_CurrentCity:
		{
			if (!needUpdateForCurrentyCity)
				return;
			for (GTFS_City *aCity in updateCitiesFromServer)
			{
				if ([aCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
				{
					updatingCity = aCity;
					downloadingNewCity = NO;
					downloadState = kDownloadStateSelected;
					[self updateCityToLocal];
					return;
				}
			}
			NSAssert(NO, @"Couldn't find current city in update list!!");
			break;
		}
		case kUIUpdate_NewCity:
			if ([newCitiesFromServer count] > 0)
			{
				updatingCity = [newCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = YES;
				downloadState = kDownloadStateSelected;
				[self updateCityToLocal];
				return;
			}
			break;
		case kUIUpdate_UpdatedCity:
			if ([updateCitiesFromServer count] > 0)
			{
				updatingCity = [updateCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = NO;
				downloadState = kDownloadStateSelected;
				[self updateCityToLocal];
				return;
			}
			break;
		case kUIUpdate_AllOtherCity:
			if ([otherCitiesFromServer count] > 0)
			{
				updatingCity = [otherCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = NO;
				downloadState = kDownloadStateSelected;
				[self updateCityToLocal];
				return;
			}
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return kUIUpdate_Section_Num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case kUIUpdate_CurrentCity:
			return 1;
			break;
		case kUIUpdate_NewCity:
			if ([newCitiesFromServer count] > 0)
				return [newCitiesFromServer count];
			else
				return 1;
			break;
		case kUIUpdate_UpdatedCity:
			if ([updateCitiesFromServer count] > 0)
				return [updateCitiesFromServer count];
			else
				return 1;
			break;
		case kUIUpdate_AllOtherCity:
			if ([otherCitiesFromServer count] > 0)
				return [otherCitiesFromServer count];
			else
				return 1;
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kUIUpdate_CurrentCity:
			NSAssert([[UIApplication sharedApplication] isKindOfClass:[TransitApp class]], @"Application mismatch!");
			return [(TransitApp *)[UIApplication sharedApplication] currentCity];
			break;
		case kUIUpdate_NewCity:
			return @"Newly-added cities";
			break;
		case kUIUpdate_UpdatedCity:
			return @"Newly-updated cities";
			break;
		case kUIUpdate_AllOtherCity:
			return @"Other supported cities";
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtCityUpdateView";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textAlignment = UITextAlignmentCenter;
		//cell.font = [UIFont systemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case kUIUpdate_CurrentCity:
			if (!needUpdateForCurrentyCity)
				cell.text = @"Already up to date";
			else
				cell.text = @"New update available";
			break;
		case kUIUpdate_NewCity:
			if ([newCitiesFromServer count] == 0)
				cell.text = @"None";
			else
			{
				GTFS_City *theCity = [newCitiesFromServer objectAtIndex:indexPath.row];
				cell.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
			}
			break;
		case kUIUpdate_UpdatedCity:
			if ([updateCitiesFromServer count] == 0)
				cell.text = @"None";
				else
				{
					GTFS_City *theCity = [updateCitiesFromServer objectAtIndex:indexPath.row];
					cell.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
				}
			break;
		case kUIUpdate_AllOtherCity:
			if ([otherCitiesFromServer count] == 0)
				cell.text = @"None";
				else
				{
					GTFS_City *theCity = [otherCitiesFromServer objectAtIndex:indexPath.row];
					cell.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
				}
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
	
	return cell;
}

#pragma mark Download Manager
- (void)startDownloadingURL:(NSString *) urlString
{
	// open a dialog with an OK and cancel button
	downloadActionSheet = [[UIActionSheet alloc] initWithTitle:@"Downloading (0.0 %%)"
													  delegate:self
											 cancelButtonTitle:@"Cancel" 
										destructiveButtonTitle:nil 
											 otherButtonTitles:nil];
	downloadActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[downloadActionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[downloadActionSheet release];	
	
	// create the request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:TIMEOUT_DOWNLOAD];
	// create the connection with the request
	// and start loading the data
	theDownload=[[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
	if (!theDownload) {
		NSLog(@"Fail to initiate download!!");
	}	
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
	NSString *destinationFilename;
	NSString *homeDirectory=NSHomeDirectory();
	
	destinationFilename=[[homeDirectory stringByAppendingPathComponent:@"Downloads"]
						 stringByAppendingPathComponent:filename];
	[download setDestination:destinationFilename allowOverwrite:YES];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	// release the connection
	[download release];
	
	// inform the user
	NSLog(@"Download failed! Error - %@ %@",
		  [error localizedDescription],
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	// release the connection
	[download release];
	[downloadActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
	
	// do something with the data
	NSLog(@"%@",@"downloadDidFinish");
	downloadState = kDownloadStateDownloaded;
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	NSString *oldDatabase = [[myApplication localDatabaseDir] stringByAppendingPathComponent:updatingCity.dbname];
	NSString *newDatabase = [[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]
							 stringByAppendingPathComponent:updatingCity.dbname];
		
	//Copy favorites table if needed.
	if ((!downloadingNewCity) && (!overwriteFavorites))
	{
		[self copyFavoriteTableFrom:oldDatabase to:newDatabase];
	}
	
	//Copy database file to local directory.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if ([fileManager fileExistsAtPath:oldDatabase])
	{
		if (![fileManager removeItemAtPath:oldDatabase error:&error])
		{
			NSAssert1(0, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
			return;
		}
		NSLog(@"Delete file: %@", oldDatabase);
	}
	
	if (![fileManager copyItemAtPath:newDatabase toPath:oldDatabase error:&error])	
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return;
	}	
	NSLog(@"Copy database to %@", oldDatabase);
	
	downloadState = kDownloadStateIdle;
	if (downloadingNewCity)
	{
		[self addCityToLocalGTFSInfo:updatingCity];
		[otherCitiesFromServer addObject:updatingCity];
		[newCitiesFromServer removeObject:updatingCity];
	}
	else if ([otherCitiesFromServer indexOfObject:updatingCity] == NSNotFound)
	{
		if ([updatingCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
			needUpdateForCurrentyCity = NO;
			
		[self updateCityToLocalGTFSInfo:updatingCity];
		[otherCitiesFromServer addObject:updatingCity];
		[updateCitiesFromServer removeObject:updatingCity];
	}
	else
	{
		[self updateCityToLocalGTFSInfo:updatingCity];
	}
	updatingCity = nil;
	[updateTableView reloadData];	
}

//-(void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
//{
	// path now contains the destination path
	// of the download, taking into account any
	// unique naming caused by -setDestination:allowOverwrite:
	//NSLog(@"Final file destination: %@",path);
//}

- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse
{
	[aDownloadResponse retain];
	[downloadResponse release];
	downloadResponse = aDownloadResponse;
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
	// reset the progress, this might be called multiple times
	bytesReceived=0;
	
	// retain the response to use later
	[self setDownloadResponse:response];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length
{
	long long expectedLength=[downloadResponse expectedContentLength];
	
	bytesReceived=bytesReceived+length;
	
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

@end
