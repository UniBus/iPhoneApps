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
#import <zlib.h>

#define CHUNK 16384	//16K
#define TIMEOUT_DOWNLOAD	60.0

/*
extern const NSString *GTFSUpdateURL;
extern BOOL  cityUpdateAvailable;
extern BOOL  offlineUpdateAvailable;
extern BOOL  offlineDownloaded;
*/

const NSString *OfflineURL = @"http://zyao.servehttp.com:5144/ver1.4/offline/cache.php";	
const NSString *GTFSUpdateURL = @"http://zyao.servehttp.com:5144/ver1.4/updates/";

BOOL  cityUpdateAvailable = NO;
BOOL  offlineUpdateAvailable = NO;
BOOL  offlineDownloaded = NO;

enum CityUpdateSections
{
	kUIUpdate_Online = 0,
	kUIUpdate_Offline,
	kUIUpdate_Section_Num
};

enum CityUpdateStatus
{
	kCityDatabaseError = -1,
	kCityUnChanged = 0,
	kCityNewlyAdded,
	kCityNewlyUpdated
};

enum CurrentCityUpdateStatus
{
	kCurrentCityUnselected = 0,
	kCurrentCityNeedsUpdate,
	kCurrentCityUpdated,
};

enum DownloadingType
{
	kDownloadCityDatabase = 0, 
	kDownloadOfflineDatabase
};

@interface CityUpdateViewController (private)
UIActionSheet    *unzipActionSheet;
NSMutableArray	*allLocalCities;
int              downloadingDbType;
int              totalOfflineDbSize;
BOOL             unzippingCancelled;
- (NSInteger) checkCityInLocalDb: (NSString *)city lastUpdate:(NSString *)updateDate;
- (void) getAllLocalCities;
- (void)startDownloadingURL:(NSString *) urlString asFile:(NSString *) fileName;

- (void)cityDbFileDownloaded:(NSString *)destinationFilename;
- (void)offlineDbFileDownloaded:(NSString *)destinationFilename;
- (void) offlineDbFileUnzipped:(NSString *)downloadedOfflineDb;

@end

@implementation CityUpdateViewController

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	updateTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
												   style:UITableViewStylePlain]; 
	[updateTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth]; 
	updateTableView.delegate = self;
	updateTableView.dataSource = self;
	self.view = updateTableView; 

	[self getAllLocalCities];
	[self checkUpdates];
	[updateTableView reloadData];
	
	self.navigationItem.title = @"Updates";
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
	
	[allLocalCities release];
	allLocalCities = nil;
}


- (void)dealloc 
{
	[allLocalCities release];
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
	 *    (id, name, state, country, website, dbname, lastupdate, lastupdatelocal, local, oldbtime, oldbtimelocal, oldbdownloaded)
	 */
	NSString *sql = [NSString stringWithFormat:@
					 "UPDATE cities SET website='%@', dbname='%@', "
					 "name='%@', state='%@', country='%@', "
					 "lastupdate='%@', lastupdatelocal='%@', local=%d, "
					 "oldbtime='%@', oldbtimelocal='%@', oldbdownloaded=%d "
					 "WHERE id='%@'",
					 aCity.website, aCity.dbname, 
					 aCity.cname, aCity.cstate, aCity.country,
					 aCity.lastupdate, aCity.lastupdatelocal, aCity.local,
					 aCity.oldbtime, aCity.oldbtimelocal, aCity.oldbdownloaded,
					 aCity.cid];
	
	if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) 
		NSLog(@"Error: %s", sqlite3_errmsg(database));		
	
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

/*!
 * \brief Get all cities from local gtfs_info.cities.
 *
 * \return a NSMutableArray with all local
 *     
 */
- (void) getAllLocalCities
{	
	[allLocalCities release];
	allLocalCities = [[NSMutableArray alloc] init];
	
	TransitApp *myApplication = (TransitApp *) [UIApplication sharedApplication];
	sqlite3 *database;
	if (sqlite3_open([[myApplication gtfsInfoDatabase] UTF8String], &database) != SQLITE_OK) 
		return;
	
	/* cities db has the following fileds:
	 *    (id, name, state, country, website, dbname, lastupdate, lastupdatelocal, local, oldbtime, oldbtimelocal, oldbdownloaded)
	 */
	NSString *sql = [NSString stringWithFormat:@
					 "SELECT id, name, state, country, website, dbname, lastupdate, lastupdatelocal, local, oldbtime, oldbtimelocal, oldbdownloaded "
					 "FROM cities"];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
	{
		if (sqlite3_step(statement) == SQLITE_ROW)
		{
			GTFS_City *city = [[GTFS_City alloc] init];
			
			// All properties are (retain)
			city.cid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			city.cname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			city.cstate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			city.country = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			city.website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			city.dbname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			city.lastupdate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			city.lastupdatelocal = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
			city.local = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)] intValue];
			if (sqlite3_column_text(statement, 9) == NULL)
				city.oldbtime = @"";
			else
				city.oldbtime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 9)];
			if (sqlite3_column_text(statement, 10) == NULL)
				city.oldbtimelocal = @"";
			else
				city.oldbtimelocal = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 10)];
			if (sqlite3_column_text(statement, 11) == NULL)
				city.oldbdownloaded = 0;
			else
				city.oldbdownloaded = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 11)] intValue];
			// Notes:
			//     [NSString intValue] return 0 if the string is invalid
			
			[allLocalCities addObject:city];
			[city release];
		}
		else
			NSLog(@"Error in getAllLocalCities (sqlite3_step): %s", sqlite3_errmsg(database));
	}
	else
		NSLog(@"Error in getAllLocalCities (sqlite3_prepare_v2): %s", sqlite3_errmsg(database));		

	sqlite3_finalize(statement);		
	sqlite3_close(database);
}

- (BOOL) updateCityInfoFromServer:(GTFS_City *)city
{
	GTFS_City *updatedCity = NULL;
	for (GTFS_City *localCity in allLocalCities)
	{
		if ([localCity isSameCity:city])
		{
			updatedCity = localCity;
			break;
		}
	}
	
	if (updatedCity == NULL)
		return NO;
	
	if ([updatedCity isEqualTo:city])
		return NO;
	
	updatedCity.cname = city.cname;
	updatedCity.cstate = city.cstate;
	updatedCity.country = city.country;
	updatedCity.website = city.website;
	updatedCity.dbname = city.dbname;
	updatedCity.lastupdate = city.lastupdate;
	updatedCity.oldbtime = city.oldbtime;
	
	[self updateCityToLocalGTFSInfo:updatedCity];
	return YES;
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
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[parser abortParsing];

	[[UIApplication sharedApplication] performSelectorOnMainThread:@selector(userAlert:) withObject:@"Update failed!" waitUntilDone:NO];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	GTFS_City *city = [[GTFS_City alloc] init];
	if ([elementName isEqualToString:@"city"]) 
	{
		city.cid = [attributeDict valueForKey:@"id"];
		city.cname = [attributeDict valueForKey:@"name"];
		city.cstate = [attributeDict valueForKey:@"state"];
		city.country = [attributeDict valueForKey:@"country"];
		city.website = [attributeDict valueForKey:@"website"];
		city.dbname = [attributeDict valueForKey:@"dbname"];
		city.lastupdate = [attributeDict valueForKey:@"lastupdate"];
		city.oldbtime = [attributeDict valueForKey:@"oldbtime"];
		
		[self updateCityInfoFromServer:city];
	}
	[city release];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	//[arrivalsForStops sortUsingSelector:@selector(compare:)];
	[updateTableView reloadData];
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
- (void) askBeforeUpdatingCityToLocal
{
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet;
	//NSString *otherButtonTitle = nil;
	actionSheet = [[UIActionSheet alloc] initWithTitle:applicationTitle
														 delegate:self
												cancelButtonTitle:@"Cancel" 
										   destructiveButtonTitle:@"Overwrite" 
												otherButtonTitles:@"Overwrite, Keep Favorites", nil];

	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];	
}

- (void) updateCityDbToLocal: (GTFS_City *) city
{
	NSString *urlString = [NSString stringWithFormat:@"%@%@", GTFSUpdateURL, city.dbname];
	[self startDownloadingURL:urlString asFile:city.dbname];
}

- (void) updateOfflineDbToLocal: (GTFS_City *) city
{
	NSString *currentDbName = [NSString stringWithFormat:@"ol-%@.zip", city.dbname];
	NSString *urlString = [NSString stringWithFormat:@"%@?%@", OfflineURL, city.cid];
	
	[self startDownloadingURL:urlString asFile:currentDbName];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)theButtonIndex
{
	if (downloadingDbType == kDownloadCityDatabase)
	{
		if (theButtonIndex == actionSheet.cancelButtonIndex) 
			updatingCity = nil;	
		else
		{
			overwriteFavorites = YES;		
			if (theButtonIndex == actionSheet.firstOtherButtonIndex) 
				overwriteFavorites = NO;
			
			[self updateCityDbToLocal:updatingCity];
		}
	}
	else
		unzippingCancelled = YES;
}

#pragma mark TableView Delegate Functions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case kUIUpdate_Online:
			updatingCity = [allLocalCities objectAtIndex:indexPath.row];
			downloadingDbType = kDownloadCityDatabase;
			[self askBeforeUpdatingCityToLocal];
			break;
		case kUIUpdate_Offline:
			updatingCity = [allLocalCities objectAtIndex:indexPath.row];
			downloadingDbType = kDownloadOfflineDatabase;
			unzippingCancelled = NO;
			[self updateOfflineDbToLocal:updatingCity];
			break;
		default:
			NSAssert(NO, @"Something is wrong: wrong section index!!");
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [allLocalCities count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kUIUpdate_Online:
			return @"City database (stops & routes)";
		case kUIUpdate_Offline:
			return @"Offline schedules";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *MyIdentifier = @"CellIdentifierAtCityUpdateView";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) 
	{
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		//cell.textColor = [UIColor blueColor];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case kUIUpdate_Online:
			if ([allLocalCities count] == 0)
				cell.textLabel.text = @"None";
			else
			{
				GTFS_City *theCity = [allLocalCities objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
				if ([theCity.lastupdate compare: theCity.lastupdatelocal] == NSOrderedDescending)
				{
					cell.detailTextLabel.textColor = [UIColor redColor];
					cell.detailTextLabel.text = @"New update available";
				}
				else
					cell.detailTextLabel.text = @"Already up to date";
			}
			break;
		case kUIUpdate_Offline:
			if ([allLocalCities count] == 0)
				cell.textLabel.text = @"None";
			else
			{
				GTFS_City *theCity = [allLocalCities objectAtIndex:indexPath.row];
				cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@", theCity.cname, theCity.cstate, theCity.country];
				if (!theCity.oldbdownloaded)
					cell.detailTextLabel.text = @"Not cached yet";
				else if ([theCity.oldbtime compare: theCity.oldbtimelocal] == NSOrderedDescending)
				{
					cell.detailTextLabel.textColor = [UIColor redColor];
					cell.detailTextLabel.text = @"New offline schedule available";
				}
				else
					cell.detailTextLabel.text = @"Already up to date";
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
	if (downloadingDbType == kDownloadCityDatabase)
		[self cityDbFileDownloaded:destinationFilename];
	else
		[self offlineDbFileDownloaded:destinationFilename];
}


- (void)cityDbFileDownloaded:(NSString *)destinationFilename
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
	if (!overwriteFavorites)
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
		
	if ([updatingCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
	{
		statusOfCurrentyCity = kCurrentCityUpdated;
		cityUpdateAvailable = NO;
		if (offlineUpdateAvailable)
			[UIApplication sharedApplication].applicationIconBadgeNumber = 1;
		else
			[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

		//To engage the new database.
		[myApplication performSelector:@selector(resetCurrentCity)];
	}
		
	updatingCity.lastupdatelocal = updatingCity.lastupdate;
	[self updateCityToLocalGTFSInfo:updatingCity];

	updatingCity = nil;
	[updateTableView reloadData];	
}


- (void)offlineDbFileDownloaded:(NSString *)destinationFilename
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

- (void) offlineDbFileUnzipped:(NSString *)downloadedOfflineDb
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
		[myApplication performSelectorOnMainThread:@selector(userAlert:) withObject:@"Download schedule invalid!" waitUntilDone:NO];
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
		
	[unzipActionSheet  dismissWithClickedButtonIndex:-1 animated:NO];

	//Update database
	//NSString *currentCityId = [(TransitApp *)[UIApplication sharedApplication] currentCityId];
	//NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	//[formatter setDateFormat:@"yyyyMMdd"];
	//NSString *downloadTime = [formatter stringFromDate:[NSDate date]];
	//updateOfflineDbInfoInGTFS(currentCityId, 1, downloadTime);	
	updatingCity.oldbtimelocal = updatingCity.oldbtime;
	updatingCity.oldbdownloaded = 1;
	[self updateCityToLocalGTFSInfo:updatingCity];
	if ([updatingCity.cid isEqualToString:[(TransitApp *)[UIApplication sharedApplication] currentCityId]])
	{
		offlineUpdateAvailable = NO;
		offlineDownloaded = YES;
	}

	updatingCity = nil;
	[updateTableView reloadData];	
}

#pragma mark Unziping files
- (void) unzipingStatusUpdateSizeReceived:(NSNumber *)size
{
	totalOfflineDbSize = [size intValue] * 5;  
	/* This is a very rough estimation, 
	 * since zlib couldnt provide the size of orginal file.
	 */
}

- (void) unzipingStatusUpdateChunkUnzipped:(NSNumber *)size
{
	int receivedSize = [size intValue];
	if (totalOfflineDbSize == 0)
	{
		[unzipActionSheet setTitle:[NSString stringWithFormat:@"Installing %d (KBytes)", receivedSize/1024]];
	}
	else
	{
		float percentComplete = 0;
		if (receivedSize > totalOfflineDbSize)
			percentComplete = 100.;
		else
			percentComplete=(receivedSize/(float)totalOfflineDbSize)*100.0;
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
		[self performSelectorOnMainThread:@selector(offlineDbFileUnzipped:) withObject:destPath waitUntilDone:NO];
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

@end
