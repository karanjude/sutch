import MySQLdb as mysql
import os
import urllib
import json

def get_user_data(access_token):
    url = "https://graph.facebook.com/me?access_token=%s" % (access_token)
    stream = urllib.urlopen(url)
    data = stream.read()
    print data
    json_data = json.loads(data)
    user_id = json_data["id"]
    if json_data.has_key("username"):
        user_name = json_data["username"]
    else:
        user_name = json_data["name"]
    return user_id, user_name



conn = mysql.connect('localhost','root','','data')
select_cursor = conn.cursor()

select_cursor.execute("select * from authentication where user_id is NULL")
for data in select_cursor.fetchall():
    access_token = data[0]
    user_id , user_name = get_user_data(access_token)
    update_statement = "update authentication set user_id = %s , user_name = '%s' where access_token = '%s'" % (user_id, user_name, access_token)
    print "excecuting " , update_statement
    update_cursor = conn.cursor()
    update_cursor.execute(update_statement)
    update_cursor.close()

select_cursor.close()
conn.close()
