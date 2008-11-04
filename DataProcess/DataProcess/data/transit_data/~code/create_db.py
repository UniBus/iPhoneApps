import csv
import MySQLdb
import sys
import string
import os

if len(sys.argv)< 2:
    print 'Usage:'
    print '\t %s  dbName' % (os.path.basename(sys.argv[0]))
    print ''
    sys.exit(1)
    
dbname = sys.argv[1]
#dbname = "test_trimet" 

try:
    #create database if it doesn't exist
    conn = MySQLdb.connect(host = "localhost",
                           user = "root",
                           passwd = "awang")		
    cursor = conn.cursor()
    cursor.execute("""CREATE DATABASE IF NOT EXISTS """ + dbname)
    conn.commit()
    conn.close()	
	
except MySQLdb.Error, e:
    print "Error %d %s" % (e.args[0], e.args[1])
    sys.exit(1)		

