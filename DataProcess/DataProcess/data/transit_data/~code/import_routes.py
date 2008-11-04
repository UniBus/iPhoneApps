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
filename = os.path.join(sys.argv[2], "routes.txt")

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
    cursor.execute ("DROP TABLE IF EXISTS routes")
    cursor.execute ("""CREATE TABLE routes (
                        route_id CHAR(32) PRIMARY KEY,
                        route_short_name CHAR(32),
                        route_long_name CHAR(128),
                        route_type CHAR(10)
                        )
                    """)
		
	
    #insert record
    cvsfile = open(filename)
    headerreader = csv.reader(cvsfile,skipinitialspace=True)
    fieldnames = headerreader.next()
    reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
    #print fieldnames
    
    for rowvalues in reader:
        route_id = rowvalues['route_id'].strip()
        route_short_name = rowvalues['route_short_name']
        route_long_name = rowvalues['route_long_name']
        route_type = rowvalues['route_type']
        cursor.execute("""
                    INSERT INTO routes (route_id,route_short_name,route_long_name, route_type)
                    VALUE
                    (%s, %s, %s, %s)
                    """, (route_id,route_short_name,route_long_name, route_type))
			
    #check
    cursor.execute("SELECT * FROM routes")
    print "Number of record imported: %d" % cursor.rowcount
    
    #close down
    cursor.close()
    cvsfile.close()

except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

conn.commit()
conn.close()

