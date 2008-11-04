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
filename = os.path.join(sys.argv[2], "calendar.txt")

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
    cursor.execute ("DROP TABLE IF EXISTS calendar")
    cursor.execute ("""CREATE TABLE calendar (
                        service_id CHAR(32) PRIMARY KEY,                        
                        monday INT,
                        tuesday INT,
                        wednesday INT,
                        thursday INT,
                        friday INT,
                        saturday INT,
                        sunday INT,
                        start_date CHAR(32),
                        end_date CHAR(32)                        
                        )
                    """)
		
	
    #insert record
    cvsfile = open(filename)
    headerreader = csv.reader(cvsfile,skipinitialspace=True)
    fieldnames = headerreader.next()
    reader = csv.DictReader(cvsfile, fieldnames, restkey='unknown', restval='',skipinitialspace=True)
    #print fieldnames
    
    for rowvalues in reader:
        cursor.execute("""
            INSERT INTO calendar (service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date)
            VALUE
            (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (rowvalues['service_id'].strip(),rowvalues['monday'],rowvalues['tuesday'],rowvalues['wednesday'],rowvalues['thursday'],rowvalues['friday'],rowvalues['saturday'],rowvalues['sunday'],rowvalues['start_date'],rowvalues['end_date']) )
			
    #check
    cursor.execute("SELECT * FROM calendar")
    print "Number of record imported: %d" % cursor.rowcount
    
    #close down
    cursor.close()
    cvsfile.close()

except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

conn.commit()
conn.close()

