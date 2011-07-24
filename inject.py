import MySQLdb as mysql
import os
import config

conn = mysql.connect(config.MYSQL_HOST_NAME, config.MYSQL_USER, config.MYSQL_USER_PASSWORD, config.MYSQL_DB)
select_cursor = conn.cursor()

seeds_file=open(os.path.join(config.SEEDS_DIR, config.URLS_FILE),"w")

select_cursor.execute("select * from authentication where used = 0")
for data in select_cursor.fetchall():
    access_token = data[0]
    company = data[1]
    used = data[2]
    if company == 'facebook':
        url = "https://graph.facebook.com/me/feed?access_token=" + access_token
    elif company == 'twitter':
        url = access_token
    print url , "written"
    seeds_file.write(url)
    seeds_file.write("\n")
select_cursor.close()
conn.close()

seeds_file.close()

