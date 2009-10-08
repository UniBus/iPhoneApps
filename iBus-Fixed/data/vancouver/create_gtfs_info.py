#!/usr/bin/python
#
#  create_gtfs_info.py
#  
#
#  Created by Zhenwang Yao on 03/11/08.
#  Copyright (c) 2008 Music Motion. All rights reserved.
#

## This module updates 'cities' table in 'gtfs_info' database
#     to reflect changes for current supported cities.
# 
# It take two parameters, as
#      import_gtfs_info $dbName $cvsFile(supportedcities.lst)
#
# Thus, it imports $cvsFile to dbName.cities.
#      if dbName.cities exists, it deletes the table first.
#
# gtfs_info.cities table structure: 
#      id CHAR(32),              #city id
#      name CHAR(32),            #name, e.g. Portland
#      state CHAR(32),           #state, e.g. OR
#      country CHAR(32),         #country, e.g. USA
#      website CHAR(128),        #url for query
#      dbname CHAR(128),         #database name
#      lastupdate CHAR(16)       #time of last update
#      lastupdatelocal CHAR(16)  #time of last update locally
#      local INTEGER             #if database has been downloaded
#      oldbtime CHAR (16)        #off-line database download time
#      oldbtimelocal CHAR (16)   #off-line database download time locally
#      oldbdownloaded INTEGER    #off-line database downloaded
#
import csv
import sqlite3
import sys
import string
import os

print "\nUniBus-SQLite-Tool Suite [gtfs_info]"
print "Import information of supported cities into a sqlite database."
print "Copyright @ Zhenwang.Yao 2008. \n"

universalSupportedFile = "../supportedcities.lst"
localSupportedFile = "./local.lst"
currentDir = os.path.abspath(".")
localGTFSInfoDb = "gtfs_info.%s"%os.path.basename(currentDir)


def AddDbInfo(version):
	print "   [*] Dropping table dbinfo, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS dbinfo")
	cursor.execute ("""CREATE TABLE IF NOT EXISTS dbinfo (
					parameter CHAR(32),
					value CHAR(32)
					)
					""")		
	print "   [*] Table dbinfo dropped, and a new one created."
	
	#insert record
	print "   [*] Insert the record into %s.dbinfo " % dbname	
	cursor.execute("INSERT INTO dbinfo (parameter, value) VALUES ('db_version', '1.2')")
	


def ReadLocalSupport(localFile):
	cities = []
	cvsfile = open(localFile)
	reader = csv.reader(cvsfile,skipinitialspace=True)
	addLines = 0
	for rowvalues in reader:
		cities.append(rowvalues[0])
		addLines += 1
		#print rowvalues[0]
	cvsfile.close()

	print "   [*] It support %d cities." %addLines
	return cities
	

dbname = localGTFSInfoDb
filename = universalSupportedFile
supportedCities = ReadLocalSupport(localSupportedFile)

print "   Converting ", filename, " into ", dbname

try:
	#create table
	print "   [*] Connecting to database %s." %dbname
	conn = sqlite3.connect(dbname, isolation_level=None)
	cursor = conn.cursor()
	print "   [*] Connected to database."

	print "   [*] Dropping table cities, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS cities")
	cursor.execute ("""CREATE TABLE IF NOT EXISTS cities (
					id CHAR(32) PRIMARY KEY,
					name CHAR(32),				
					state CHAR(32),
					country CHAR(32),
					website CHAR(128),
					dbname CHAR(128),
					lastupdate CHAR(16),
					lastupdatelocal CHAR(16),
					local INTEGER,
					oldbtime CHAR(16),
					oldbtimelocal CHAR(16),
					oldbdownloaded INTEGER
					)
					""")		
	print "   [*] Table cities dropped, and a new one created."
	
	#insert record
	cvsfile = open(filename)
	headerreader = csv.reader(cvsfile,skipinitialspace=True)
	fieldnames = headerreader.next()
	reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
	#print fieldnames

	print "   [*] Adding records into %s " % dbname
	addLines = 0;
	for rowvalues in reader:
		if not rowvalues['id'] in supportedCities:
			continue

		cursor.execute("""
				INSERT INTO cities (id, name, state, country, website, dbname, lastupdate, lastupdatelocal, local)
				VALUES
				(?, ?, ?, ?, ?, ?, ?, ?, ?)
				""", (rowvalues['id'], rowvalues['name'], rowvalues['state'], rowvalues['country'], rowvalues['website'], rowvalues['dbname'], rowvalues['lastupdate'], rowvalues['lastupdate'], '1'))
		addLines = addLines + 1
			
	#check
	#check
	#print "   [*] Comitting changes "
	print "   [*] Number of lines read from ", filename, ": %d" %addLines	
	print "   [*] Checking imported %s.cities" % dbname
	cursor.execute("SELECT COUNT(*) FROM cities")
	print "   [*] Number of row in the table: ", cursor.fetchone()[0]
	print "   [*] ===="

	print "   [*] Dropping table dbinfo, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS dbinfo")
	cursor.execute ("""CREATE TABLE IF NOT EXISTS dbinfo (
					parameter CHAR(32),
					value CHAR(32)
					)
					""")		
	print "   [*] Table dbinfo dropped, and a new one created."	
	#insert record
	print "   [*] Insert the record into %s.dbinfo " % dbname	
	cursor.execute("INSERT INTO dbinfo (parameter, value) VALUES ('db_version', '1.4')")
	print "   [*] Done \n"

	#close down
	cursor.close()
	cvsfile.close()

except:
	print "Error occured during importing!!  Possibly around Line: %d" %addLines
	sys.exit(1)		

conn.commit()
conn.close()
