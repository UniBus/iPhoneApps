#!/usr/bin/python
#
#  add_favorites.py
#
#  Created by Zhenwang Yao on 03/11/08.
#  Copyright (c) 2008 Music Motion. All rights reserved.
#

## This module add a 'favorites' table in a city database.
# 
# It take two parameters, as
#      add_favorites $dbName
#
# Thus, it creates an empty favorite table into the database.
#
# favorites table structure: 
#      stop_id CHAR(16),
#      route_id CHAR(32),
#      route_name CHAR(32),
#      bus_sign CHAR(128)",
#
import csv
import sqlite3
import sys
import string
import os

print "\nUniBus-Tool Suite [favorites]"
print "Add an empty favorite table into a sqlite database."
print "Copyright @ Zhenwang.Yao 2008. \n"

if len(sys.argv) < 2:
	print 'Usage:'
	print '\t %s  dbName' % (os.path.basename(sys.argv[0]))
	print ''
	sys.exit(1)

dbname = sys.argv[1]
print "   Adding db-information into ", dbname

try:
	#create table
	print "   [*] Connecting to database %s." %dbname
	conn = sqlite3.connect(dbname, isolation_level=None)
	cursor = conn.cursor()
	print "   [*] Connected to database."

	print "   [*] Dropping table favorites, and creating a new one."
	cursor.execute ("DROP TABLE IF EXISTS favorites")
	cursor.execute ("""CREATE TABLE IF NOT EXISTS favorites (
					stop_id CHAR(16),
					route_id CHAR(32),
					route_name CHAR(32),
					bus_sign CHAR(128)
					)
					""")		
	print "   [*] Table favorites dropped, and a new one created."
	
	#insert record
	print "   [*] Checking %s.favorites" % dbname
	cursor.execute("SELECT COUNT(*) FROM favorites")
	print "   [*] Number of row in the table: ", cursor.fetchone()[0]	
	print "   [*] Done \n"

	#close down
	cursor.close()

except:
	print "Error occured during importing!!"
	sys.exit(1)		

conn.commit()
conn.close()
