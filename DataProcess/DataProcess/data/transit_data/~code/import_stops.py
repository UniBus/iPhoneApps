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
filename = os.path.join(sys.argv[2], "stops.txt")

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
    cursor.execute ("DROP TABLE IF EXISTS stops")
    cursor.execute ("""CREATE TABLE stops (
                        stop_id CHAR(32) PRIMARY KEY,
                        stop_name CHAR(100),
                        stop_lat DOUBLE,
                        stop_lon DOUBLE,
                        stop_desc CHAR(128)
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
        stop_name = rowvalues['stop_name'].replace('&', '&amp;')
        stop_lat = rowvalues['stop_lat']
        stop_lon = rowvalues['stop_lon']
        try:
            stop_desc = rowvalues['stop_desc']
        except:
            stop_desc =  ''

        cursor.execute("""
                    INSERT INTO stops (stop_id, stop_name, stop_lat, stop_lon, stop_desc)
                    VALUE
                    (%s, %s, %s, %s, %s)
                    """, (stop_id, stop_name, stop_lat, stop_lon, stop_desc))
			
    #check
    cursor.execute("SELECT * FROM stops")
    print "Number of record imported: %d" % cursor.rowcount
    
    #close down
    cursor.close()
    cvsfile.close()

except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

conn.commit()
conn.close()

