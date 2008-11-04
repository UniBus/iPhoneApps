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
filename = os.path.join(sys.argv[2], "stop_times.txt")

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
    cursor.execute ("DROP TABLE IF EXISTS stop_times")
    cursor.execute ("""CREATE TABLE stop_times (
                        trip_id CHAR(32),
                        stop_id CHAR(32),
                        arrival_time CHAR(64),
                        departure_time CHAR(64),
                        stop_headsign CHAR(64),
                        INDEX stop_id USING HASH (stop_id)
                        )
                    """)
		
	
    #insert record
    cvsfile = open(filename)
    headerreader = csv.reader(cvsfile,skipinitialspace=True)
    fieldnames = headerreader.next()
    reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
    #print fieldnames

    for rowvalues in reader:
        stop_id = rowvalues['stop_id'] #.strip(), will slow down a lot
        trip_id = rowvalues['trip_id'] #.strip()
        arrival_time = rowvalues['arrival_time']
        departure_time = rowvalues['departure_time']
        try:
            stop_headsign = rowvalues['stop_headsign'].replace('&', '&amp;')
        except:
            stop_headsign = ''
        
        cursor.execute("""
                    INSERT INTO stop_times (trip_id,arrival_time,departure_time,stop_id,stop_headsign)
                    VALUE
                    (%s, %s, %s, %s, %s)
                    """, (trip_id,arrival_time,departure_time,stop_id,stop_headsign) )
			
    #check
    cursor.execute("SELECT * FROM stop_times")
    print "Number of record imported: %d" % cursor.rowcount
    
    #close down
    cursor.close()
    cvsfile.close()

except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

conn.commit()
conn.close()

