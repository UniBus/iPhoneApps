//
//  CityUpdateViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CityUpdateViewController.h"
#import "OfflineViewController.h"
#import "TransitApp.h"
#import "Upgrade.h"

#define TIMEOUT_DOWNLOAD	60.0

const NSString *GTFSUpdateURL = @"http://zyao.servehttp.com:5144/ver1.2/updates/";

BOOL  cityUpdateAvaiable = NO;
BOOL  offlineUpdateAvailable = NO;
BOOL  offlineDownloaded = NO;

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

enum CurrentCityUpdateStatus {
	kCurrentCityUnselected = 0,
	kCurrentCityNeedsUpdate,
	kCurrentCityUpdated,
};

@interface CityUpdateViewController (private)
- (NSInteger) checkCityInLocalDb: (NSString *)city lastUpdate:(NSString *)updateDate;
- (void) checkUpdates;
- (void)startDownloadingURL:(NSString *) urlString asFile:(NSString *) fileName;
@end

@implementation CityUpdateViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	updateTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
												   style:UITableViewStyleGrouped]; 
	[updateTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	updateTableView.delegate = self;
	updateTableView.dataSource = self;
	self.view = updateTableView; 

	[self checkUpdates];
	[updateTableView reloadData];
	
	self.navigationItem.title = @"Online Update";
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
	[newCitiesFromServer release];
	[updateCitiesFromServer release];
	[otherCitiesFromServer release];
	[downloader release];
	[updateTableView release];
	[super dealloc];
}

- (BOOL) updateAvaiable //This is for current city only
{
	return (statusOfCurrentyCity == kCurrentCityNeedsUpdate);	
}

- (BOOL) newOfflineDatabaseAvailable
{
	return (statusOfCurrentyCityOfflineDb == kCurrentCityNeedsUpdate);	
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
	NSString *appCurrentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];	
	if (appCurrentCityId == nil)
	{
		statusOfCurrentyCity = kCurrentCityUnselected;
		statusOfCurrentyCityOfflineDb = kCurrentCityUnselected;
	}
	else if ([appCurrentCityId isEqualToString:@""])
	{
		statusOfCurrentyCity = kCurrentCityUnselected;
		statusOfCurrentyCityOfflineDb = kCurrentCityUnselected;
	}
	else
	{
		statusOfCurrentyCity = kCurrentCityUpdated;
		statusOfCurrentyCityOfflineDb = kCurrentCityUpdated;
	}
		
	cityUpdateAvaiable = NO;
	offlineUpdateAvailable = NO;
	[otherCitiesFromServer release];
	[newCitiesFromServer release];
	[updateCitiesFromServer release];
	otherCitiesFromServer = [[NSMutableArray alloc] init];
	newCitiesFromServer = [[NSMutableArray alloc] init];
	updateCitiesFromServer = [[NSMutableArray alloc] init];	
	
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
	
	/*
	statusOfCurrentyCity = kCurrentCityUpdated;
	NSString *appCurrentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];	
	if (appCurrentCityId == nil)
		statusOfCurrentyCity = kCurrentCityUnselected;
	else if ([appCurrentCityId isEqualToString:@""])
		statusOfCurrentyCity = kCurrentCityUnselected;
	else
		for (GTFS_City *aCity in updateCitiesFromServer)
		{
			if ([aCity.cid isEqualToString:appCurrentCityId])
			{
				statusOfCurrentyCity = kCurrentCityNeedsUpdate;
				break;
			}
		}
	 */
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
		city.oldbtime = [attributeDict valueForKey:@"oldbtime"];
		
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
		
		NSString *appCurrentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];
		if ([city.cid isEqualToString:appCurrentCityId])
		{
			//Obvious current city is impossible to be a "newly-added" city
			if (status == kCityNewlyUpdated)
				statusOfCurrentyCity = kCurrentCityNeedsUpdate;
			
			NSString *offlineDbTime = offlineDbDownloadTime(appCurrentCityId);
			if (offlineDbDownloaded(appCurrentCityId))
			{
				offlineDownloaded = YES;
				if ([city.oldbtime compare:offlineDbTime] == NSOrderedDescending)
					//meaning there is a newer offline database available
					statusOfCurrentyCityOfflineDb = kCurrentCityNeedsUpdate;
				else
					statusOfCurrentyCityOfflineDb = kCurrentCityUpdated;				
			}
			cityUpdateAvaiable = (statusOfCurrentyCity == kCurrentCityNeedsUpdate);
			offlineUpdateAvailable = (statusOfCurrentyCityOfflineDb == kCurrentCityNeedsUpdate);
		}
		
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
	if (theButtonIndex == actionSheet.cancelButtonIndex) 
	{
		updatingCity = nil;	
	}
	else
	{
		NSString *urlString = [NSString stringWithFormat:@"%@%@", GTFSUpdateURL, updatingCity.dbname];
		[self startDownloadingURL:urlString asFile:updatingCity.dbname];

		overwriteFavorites = YES;		
		if (theButtonIndex == actionSheet.firstOtherButtonIndex) 
			overwriteFavorites = NO;
	}	
}

#pragma mark TableView Delegate Functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kUIUpdate_CurrentCity:
		{
			if (statusOfCurrentyCity == kCurrentCityNeedsUpdate)
			{
				for (GTFS_City *aCity in updateCitiesFromServer)
				{
					if ([aCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
					{
						updatingCity = aCity;
						downloadingNewCity = NO;
						[self updateCityToLocal];
					}
				}
			}
			break;
		}
		case kUIUpdate_NewCity:
			if ([newCitiesFromServer count] > 0)
			{
				updatingCity = [newCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = YES;
				[self updateCityToLocal];
			}
			break;
		case kUIUpdate_UpdatedCity:
			if ([updateCitiesFromServer count] > 0)
			{
				updatingCity = [updateCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = NO;
				[self updateCityToLocal];
			}
			break;
		case kUIUpdate_AllOtherCity:
			if ([otherCitiesFromServer count] > 0)
			{
				updatingCity = [otherCitiesFromServer objectAtIndex:indexPath.row];
				downloadingNewCity = NO;
				[self updateCityToLocal];
			}
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
			return @"Other cities (updated)";
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
		cell.font = [UIFont boldSystemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case kUIUpdate_CurrentCity:
			if (statusOfCurrentyCity == kCurrentCityUpdated)
				cell.text = @"Already up to date";
			else if (statusOfCurrentyCity == kCurrentCityNeedsUpdate)
				cell.text = @"New update available";
			else
				cell.text = @"City not selected yet!";
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

#pragma mark Download Deletegate Functions
- (void)fileDownloaded:(NSString *)destinationFilename
{	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];

	//First needs to check if the downloaded database is valid.
	if (!isValidDatabase(destinationFilename))
	{
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download data invalid!" waitUntilDone:NO];
		return;
	}
	
	NSString *oldDatabase = [[myApplication localDatabaseDir] stringByAppendingPathComponent:updatingCity.dbname];
	NSString *newDatabase = destinationFilename;
		
	//Copy favorites table if needed.
	if ((!downloadingNewCity) && (!overwriteFavorites))
	{
		if (upgradeNeeded(oldDatabase))
			upgrade(oldDatabase, newDatabase);
		
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
	
	if (![fileManager moveItemAtPath:newDatabase toPath:oldDatabase error:&error])	
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return;
	}	
	NSLog(@"Move database from %@", newDatabase);
		
	if (downloadingNewCity)
	{
		[self addCityToLocalGTFSInfo:updatingCity];
		[otherCitiesFromServer addObject:updatingCity];
		[newCitiesFromServer removeObject:updatingCity];
	}
	else
	{
		if ([updatingCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
		{
			statusOfCurrentyCity = kCurrentCityUpdated;
			cityUpdateAvaiable = NO;
			if (offlineUpdateAvailable)
				[UIApplication sharedApplication].applicationIconBadgeNumber = 1;
			else
				[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

			//To engage the new database.
			[myApplication performSelector:@selector(resetCurrentCity)];
		}
			
		[self updateCityToLocalGTFSInfo:updatingCity];
		if ([otherCitiesFromServer indexOfObject:updatingCity] == NSNotFound)
		{
			[otherCitiesFromServer addObject:updatingCity];
			[updateCitiesFromServer removeObject:updatingCity];
		}
	}

	updatingCity = nil;
	[updateTableView reloadData];	
}

@end
