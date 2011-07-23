import MySQLdb as mysql
import os
import config

conn = mysql.connect(config.MYSQL_HOST_NAME,config.MYSQL_USER,config.MYSQL_USER_PASSWORD,config.MYSQL_DB)
update_cursor = conn.cursor()

update_cursor.execute("update authentication set used=1")
update_cursor.close()
conn.close()

