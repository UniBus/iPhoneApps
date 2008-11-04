import csv
import MySQLdb
import sys
import string
import os

if len(sys.argv)< 3:
    print 'Usage:'
    print '\t %s  dbName cvsFilePath' % (os.path.basename(sys.argv[0]))
    print ''
    sys.exit(1)
    
dbname = sys.argv[1]
#dbname = "test_trimet" 
filename = os.path.join(sys.argv[2], "trips.txt")

try:
    #create database if it doesn't exist
    #call create_db.py to create if needed
	
    #connect to the database
    conn = MySQLdb.connect(host = "localhost",
                           user = "root",
                           passwd = "awang",
                           db = dbname)		
	
except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		


try:
    #create table
    cursor = conn.cursor()
    cursor.execute ("DROP TABLE IF EXISTS trips")
    cursor.execute ("""CREATE TABLE trips (
                        trip_id CHAR(32),
                        route_id CHAR(32),
                        service_id CHAR(32),
                        direction_id CHAR(16),
                        block_id CHAR(16),
                        trip_headsign CHAR(128),
                        INDEX trip_id USING HASH (trip_id)
                        )
                    """)
		
	
    #insert record
    cvsfile = open(filename)
    headerreader = csv.reader(cvsfile,skipinitialspace=True)
    fieldnames = headerreader.next()
    reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
    #print fieldnames
    
    for rowvalues in reader:
        route_id = rowvalues['route_id'] #.strip(), will slow down a lot
        service_id = rowvalues['service_id'] #.strip()
        trip_id = rowvalues['trip_id'].strip()
        try:
            direction_id = rowvalues['direction_id']
        except:
            direction_id = ''
        block_id = rowvalues['block_id']
        try:
            trip_headsign = rowvalues['trip_headsign'].replace('&', '&amp;')
        except:
            trip_headsign = ''            
        cursor.execute("""
                    INSERT INTO trips (route_id,service_id,trip_id,direction_id,block_id,trip_headsign)
                    VALUE
                    (%s, %s, %s, %s, %s, %s)
                    """, (route_id,service_id,trip_id,direction_id,block_id,trip_headsign))
			
    #check
    cursor.execute("SELECT * FROM trips")
    print "Number of record imported: %d" % cursor.rowcount
    
    #close down
    cursor.close()
    cvsfile.close()

except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

conn.commit()
conn.close()

