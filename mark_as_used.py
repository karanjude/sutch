import MySQLdb as mysql
import os

conn = mysql.connect('localhost','root','','data')
update_cursor = conn.cursor()

update_cursor.execute("update authentication set used=1")
update_cursor.close()
conn.close()

