import MySQLdb as mysql
import os
import urllib
import json

def make_post_params(access_token):
    post_params = {}
    post_params['access_token'] = access_token
    post_params['message'] = 'http://3zxx.localtunnel.com'
    post_params['link'] = 'http://3zxx.localtunnel.com'
    post_params['name'] = 'dummy link'
    post_params['description'] = 'dummy link'
    return post_params



conn = mysql.connect('localhost','root','','data')
select_cursor = conn.cursor()

select_cursor.execute("select * from authentication where posted=0")
for data in select_cursor.fetchall():
    access_token = data[0]
    user_id = data[3]
    url = 'https://graph.facebook.com/%s/feed' % (user_id)
    
    to_post = make_post_params(access_token)
    to_post = urllib.urlencode(to_post)
    
    data = urllib.urlopen(url, to_post)
    data = data.read()
    print data
    data = json.loads(data)
    if data.has_key("error"):
        print "error writing to wall"
    else:
        print "message posted to wall"
        update_statement = "update authentication set posted=1 where access_token='%s'" % (access_token)
        print update_statement
        update_cursor = conn.cursor()
        update_cursor.execute(update_statement)
        update_cursor.close()

conn.close()
