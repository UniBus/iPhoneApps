//
//  CityUpdateViewController.m
//  iBus-Universal
//
//  Created by Zhenwang Yao on 22/10/08.
//  Copyright 2008 Zhenwang Yao. All rights reserved.
//
/*! \class CityUpdateViewController
 *
 * \brief XML query/paser for information of all cities supported, and decide update status by comparing
 *        information from server, and local information in table cities of gtfs_info database.
 *
 * <b> Server Information from server (via XML) includes: </b> 
 *	- id
 *	- name, state, country
 *	- website, dbname
 *	- lastupdate (the server latest [id].sqlite update time)
 *	- oldbtime (the server latest ol-[id].sqlite update time)
 *
 * <b> The returning XML for cities.php is of the following format:</b> 
 * \code 
 *   <cities>
 *     <city id="perth" name="Perth" state="WA" country="Australia" website="http://zyao.servehttp.com:5144/ver1.2/perth/" dbname="perth.sqlite" lastupdate="20081210" oldbtime="20081201"/>
 *     <city id="vancouver" name="Vancouver" state="BC" country="Canada" website="http://zyao.servehttp.com:5144/ver1.2/vancouver/" dbname="vancouver.sqlite" lastupdate="20081220" oldbtime="20081220"/> 
 *       .... more cities ...
 *   </cities>
 * \endcode
 *
 * <b> Local gtfs_info.cities table schema:</b>
 *    \code
 *       CREATE TABLE IF NOT EXISTS cities (
 *           id CHAR(32) PRIMARY KEY, 
 *           name CHAR(32),
 *           state CHAR(32),
 *           country CHAR(32), 
 *           website CHAR(128), 
 *           dbname CHAR(128),  
 *           lastupdate CHAR(16)
 *           local INTEGER,
 *           oldbdownloaded INTEGER,
 *           oldbtime CHAR (16) 
 *          )
 * \endcode
 *
 * This class may be called in two different situations:
 *		- With the View.
 *		- Without the view.
 *
 * \todo 
 *     - CityUpdateViewController should be sub-classed from PhpXmlQuery.
 *     - The constant string GTFSUpdateURL may be better put into TransitApp. 
 *		 In fact, I think, all constant URL strings should be there, such that
 *		 later on if anything change (like version update), TransitApp is the only place
 *		 I need to look for changes.
 *     - The return XML should also include another information: 
 *     - Those updating functions seem a bit overlapped with each other,
 *       should double check and see if they can be merged.
 *     - There seems to have some limitation in updating function, and may need more investigations:
 *		 Once a city has been downloaded, there is no way to change its name/state/country>?
 *
 * \ingroup xmlquery 
 */
#import "CityUpdateViewController.h"
#import "OfflineViewController.h"
#import "TransitApp.h"
#import "Upgrade.h"

#define TIMEOUT_DOWNLOAD	60.0

const NSString *GTFSUpdateURL = @"http://zyao.servehttp.com:5144/ver1.3/updates/";

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

/*!
 * \brief Check if there is new update available for CURRENT city.
 *
 * \return
 *		- YES, if new update available.
 *		- NO, otherwise.
 *     
 */
- (BOOL) updateAvaiable //This is for current city only
{
	return (statusOfCurrentyCity == kCurrentCityNeedsUpdate);	
}

/*!
 * \brief Check if there is new offline database update available for CURRENT city.
 *
 * \return
 *		- YES, if new update available.
 *		- NO, otherwise.
 *     
 */
- (BOOL) newOfflineDatabaseAvailable
{
	return (statusOfCurrentyCityOfflineDb == kCurrentCityNeedsUpdate);	
}

#pragma mark database
/* 
 */
/** @name Database gtfs_info.tables updating functions.
 *  These functions are related to gtfs_info.tables and returned XML query result.
 */
//@{
/*!
 * \brief Add a city into local gtfs_info.cities, after download the city database.
 *
 * \param aCity The given city, with information from the server. 
 *
 * \remark
 *		- This function is only called when a new city is downloaded. 
 *		- local is always set to 1 (true).
 *		- Before downloading, such a record is most likely has been in the table, 
 *		  since flagCityToLocalGTFSInfo has been called.
 *     
 */
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
		sql = [NSString stringWithFormat:@"UPDATE cities SET website='%@', dbname='%@', name='%@', state='%@', country='%@', lastupdate='%@', local=1 WHERE id='%@'",
			   aCity.website, aCity.dbname, aCity.cname, aCity.cstate, aCity.country, aCity.lastupdate, aCity.cid];
	else
		sql = [NSString stringWithFormat:@"INSERT INTO cities (id, name, state, country, website, dbname, lastupdate, local) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)", 
					 aCity.cid, aCity.cname, aCity.cstate, aCity.country, aCity.website, aCity.dbname, aCity.lastupdate, 1];
	
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

/*!
 * \brief Update a city in local gtfs_info.cities.
 *
 * \param aCity The given city, with information from the server. 
 *
 * \remark
 *		- This function is only called when a city update is downloaded. 
 *     
 */
- (void) updateCityToLocalGTFSInfo: (GTFS_City *)aCity
{
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	/* cities db has the following fileds:
	 *    (id, name, state, country, website, dbname, lastupdate, local)
	 */
	NSString *sql = [NSString stringWithFormat:@"UPDATE cities SET website='%@', "
												"name='%@', state='%@', country='%@', "
												"dbname='%@', lastupdate='%@', local=1 "
												"WHERE id='%@'",
					 aCity.website, aCity.cname, aCity.cstate, aCity.country,
					 aCity.dbname, aCity.lastupdate, aCity.cid];
	
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
	sqlite3_close(database);	
}

/*!
 * \brief Add a supported city into local gtfs_info.cities, before downloading it.
 *
 * \param aCity The given city, with information from the server. 
 *
 * \remark
 *		- This function is only called when a newly supported city is avaible. local is always set to 0 (false). 
 *     
 */
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

/*!
 * \brief Get update status for a given city.
 *
 * \param city The given city (id)
 * \param updateDate the lastUpdate date from server.
 * \return Update status,
 *		- kCityUnChanged, no update
 *		- kCityNewlyAdded, new city
 *		- kCityNewlyUpdated, new update available
 *		- kCityDatabaseError, error occured.
 *
 */
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
//@}

/*!
 * \brief Copy current (user) favorates table into a newly-downloaded database.
 *
 * \param oldDb Existing database to be overwritten.
 * \param newDb Newly downloaded database to replace current database.
 * \return 
 *		- YES, if the table has been successfully copied.
 *		- NO, otherwise.
 *
 */
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
	
	sql = [NSString stringWithFormat:@"INSERT INTO favorites2 SELECT * FROM src.favorites2"];
	if (sqlite3_exec(destDb, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
	{
		result = NO;
		NSLog(@"Error: %s", sqlite3_errmsg(destDb));		
	}

	sqlite3_close(destDb);	
	return result;
}

#pragma mark XML query
/*!
 * \brief Initiate checking the update by requesting cities.php.
 *
 * \remarks
 *		- This function can be directly called, when checking update without UI.
 *		- When CityUpdate UI is shown, this function is called from [self loadView].
 */
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
/*!
 * \brief Initiate download of an update.
 * 
 * The response to the Alert sheet is handled in an asynchronous way, 
 * that's why the next function actionSheet is needed.
 */
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
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case kUIUpdate_CurrentCity:
			if (statusOfCurrentyCity == kCurrentCityUpdated)
				cell.textLabel.text = @"Already up to date";
			else if (statusOfCurrentyCity == kCurrentCityNeedsUpdate)
				cell.textLabel.text = @"New update available";
			else
				cell.textLabel.text = @"City not selected yet!";
			break;
		case kUIUpdate_NewCity:
			if ([newCitiesFromServer count] == 0)
				cell.textLabel.text = @"None";
			else
			{
				GTFS_City *theCity = [newCitiesFromServer objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
			}
			break;
		case kUIUpdate_UpdatedCity:
			if ([updateCitiesFromServer count] == 0)
				cell.textLabel.text = @"None";
				else
				{
					GTFS_City *theCity = [updateCitiesFromServer objectAtIndex:indexPath.row];
					cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
				}
			break;
		case kUIUpdate_AllOtherCity:
			if ([otherCitiesFromServer count] == 0)
				cell.textLabel.text = @"None";
				else
				{
					GTFS_City *theCity = [otherCitiesFromServer objectAtIndex:indexPath.row];
					cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
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
/*!
 * \brief Handling on database (city database, or offline database) downloaded.
 *
 * \param destinationFilename Downloaded database file.
 *
 */
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
