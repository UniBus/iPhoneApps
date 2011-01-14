#!/usr/bin/python
#
#  add_routes.py
#  
#
#  Created by Zhenwang Yao on 03/11/08.
#  Copyright (c) 2008 Music Motion. All rights reserved.
#

## This module import routes.txt to table 'routes' in a sqlite database
# 
# It take two parameters, as
#      import_routes $dbName $cvsFile
#
# Thus, it imports $cvsFile (routes.txt) to $dbName.routes.
#      if $dbName.routes exists, it deletes the table first.
#
# $dbName.routes table structure: 
#      route_id CHAR(16) PRIMARY KEY, 
#      route_short_name CHAR(64),
#      route_long_name CHAR(128),
#
import csv
import sqlite3
import sys
import string
import os

print "\nUniBus-Tool Suite [routes]"
print "Google Transit Feed data (routes) convertor"
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
#filename = os.path.join(sys.argv[2], "routes.txt")
print "   Converting ", filename, " into ", dbname

try:
	#create table
	print "   [*] Connecting to database %s." %dbname
	conn = sqlite3.connect(dbname, isolation_level=None)
	cursor = conn.cursor()
	print "   [*] Connected to database."

	print "   [*] Dropping table routes, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS routes")
	cursor.execute ("""CREATE TABLE routes (
		route_id CHAR(16) PRIMARY KEY, 
		route_short_name CHAR(64),
		route_long_name CHAR(128)
		)
		""")	
	print "   [*] Table routes dropped, and a new one created."

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
		route_id = rowvalues['route_id'].strip()
		route_short_name = rowvalues['route_short_name'] #.replace('&', '&amp;')
		route_long_name = rowvalues['route_long_name'] #.replace('&', '&amp;')
		
		#print route_id,route_short_name,route_long_name
		cursor.execute("""
					INSERT INTO routes (route_id,route_short_name,route_long_name)
					VALUES
					(?, ?, ?)
					""", (route_id,route_short_name,route_long_name))
		#print route_id
		addLines = addLines + 1
		
	#check
	print "   [*] Number of lines read from ", filename, ": %d" %addLines	
	print "   [*] Checking imported %s.routes" % dbname
	cursor.execute("SELECT COUNT(*) FROM routes")
	print "   [*] Number of row in the table: ", cursor.fetchone()[0]
	print "   [*] Done \n"

	#close down
	cursor.close()
	cvsfile.close()

except:
	print "Error occured during importing!!"
	sys.exit(1)		

conn.close()
