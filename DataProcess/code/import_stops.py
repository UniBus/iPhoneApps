#!/usr/bin/python
#
#  add_stops.py
#  
#
#  Created by Zhenwang Yao on 03/11/08.
#  Copyright (c) 2008 Music Motion. All rights reserved.
#

## This module import stops.txt to table 'stops' in a sqlite database
# 
# It take two parameters, as
#      import_stops $dbName $cvsFile
#
# Thus, it imports $cvsFile (stops.txt) to $dbName.stops.
#      if $dbName.stops exists, it deletes the table first.
#
# $dbName.stops table structure: 
#      stop_id CHAR(16) PRIMARY KEY,
#      stop_name CHAR(64),
#      stop_lat DOUBLE,
#      stop_lon DOUBLE,
#      stop_desc CHAR(128)
#
import csv
import sqlite3
import sys
import string
import os

print "\nUniBus-Tool Suite [stops]"
print "Google Transit Feed data convertor for stops.txt"
print "Covert GTFS data from csv format to sqlite format."
print "Copyright @ Zhenwang.Yao 2008. \n"

if len(sys.argv)< 3:
	print 'Usage:'
	print '\t %s  dbName cvsFile' % (os.path.basename(sys.argv[0]))
	print ''
	sys.exit(1)

dbname = sys.argv[1]
filename = sys.argv[2]
#dbname = "test_trimet" 
#filename = os.path.join(sys.argv[2], "stops.txt")
print "   Converting ", filename, " into ", dbname

try:
	#create table
	print "   [*] Connecting to database %s." %dbname
	conn = sqlite3.connect(dbname, isolation_level=None)
	cursor = conn.cursor()
	print "   [*] Connected to database."

	print "   [*] Dropping table stops, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS stops")
	cursor.execute ("""CREATE TABLE stops (
		stop_id CHAR(16) PRIMARY KEY,
		stop_name CHAR(64),
		stop_lat DOUBLE,
		stop_lon DOUBLE,
		stop_desc CHAR(128)
		)
		""")	
	print "   [*] Table stops dropped, and a new one created."

	#insert record
	print "   [*] Opening file %s " % filename
	cvsfile = open(filename)
	headerreader = csv.reader(cvsfile,skipinitialspace=True)
	fieldnames = headerreader.next()
	reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
	#print fieldnames

	print "   [*] Adding records into %s " % dbname
	addLines = 0;
	for rowvalues in reader:
		stop_id = rowvalues['stop_id'] #.strip(), will slow down a lot
		stop_name = rowvalues['stop_name'] #.replace('&', '&amp;')
		stop_lat = rowvalues['stop_lat']
		stop_lon = rowvalues['stop_lon']
		try:
			stop_desc = rowvalues['stop_desc'].strip()
		except:
			stop_desc =  ''

		if stop_desc == '':
			stop_desc = stop_name

		#print stop_id, stop_name, stop_lat, stop_lon, stop_desc
		cursor.execute("""
			INSERT INTO stops (stop_id, stop_name, stop_lat, stop_lon, stop_desc)
			VALUES
			(?, ?, ?, ?, ?)
			""", (stop_id, stop_name, stop_lat, stop_lon, stop_desc))
		#print stop_id
		addLines = addLines + 1
		
	#check
	print "   [*] Number of lines read from ", filename, ": %d" %addLines	
	print "   [*] Checking imported %s.stops" % dbname
	cursor.execute("SELECT COUNT(*) FROM stops")
	print "   [*] Number of row in the table: ", cursor.fetchone()[0]
	print "   [*] Done \n"

	#close down
	cursor.close()
	cvsfile.close()

except:
	print "Error occured during importing!!"
	sys.exit(1)		

conn.close()
