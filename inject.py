import MySQLdb as mysql
import os

conn = mysql.connect('localhost','root','','data')
select_cursor = conn.cursor()

seeds_file=open(os.path.join("seeds","urls"),"w")

select_cursor.execute("select * from authentication where used=0")
for data in select_cursor.fetchall():
    access_token = data[0]
    company = data[1]
    used = data[2]
    url = "https://graph.facebook.com/me/feed?access_token=" + access_token
    print url , "written"
    seeds_file.write(url)
    seeds_file.write("\n")
select_cursor.close()
conn.close()

seeds_file.close()

