import MySQLdb as mysql
import os
import json
import urllib
import sys
from subprocess import Popen, PIPE

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email import Encoders

import config


def delete_user_details(key):
    delete_statement = "delete from authentication where access_token = '%s'" % (key)
    print "excecuting " , delete_statement
    delete_cursor = conn.cursor()
    delete_cursor.execute(delete_statement)
    delete_cursor.close()


def update_user_details(user_id, user_name, key):
    update_statement = "update authentication set user_id = %s , user_name = '%s', used = 1 , posted = 1 where access_token = '%s'" % (user_id, user_name, key)
    print "excecuting " , update_statement
    update_cursor = conn.cursor()
    update_cursor.execute(update_statement)
    update_cursor.close()

def post_to_facebook_wall(user_id, url, access_token):
    post_params = {}
    post_params['access_token'] = access_token
    post_params['message'] = config.SUTCH_URL
    post_params['link'] = config.SUTCH_URL
    post_params['name'] = config.SUTCH_MESSAGE
    post_params['description'] = config.SUTCH_MESSAGE
    url = 'https://graph.facebook.com/%s/feed' % (user_id)

    to_post = urllib.urlencode(post_params)
    
    data = urllib.urlopen(url, to_post)
    data = data.read()
    #print data
    data = json.loads(data)
    if data.has_key("error"):
        raise Exception("error posting to url : %s" % (url))
    else:
        print "message posted to wall"

def post_to_twitter_timeline(url):
    try:
        print url
        data = "%s %s" % (config.SUTCH_MESSAGE, config.SUTCH_URL)
        (stdout, stderr)  = Popen(['java', '-jar', 'posttotwitter.jar', "%s" % (url), data], stdout=PIPE).communicate()
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e


def get_twitter_user_data(url):
    try:
        print url
        (stdout, stderr)  = Popen(['java', '-jar', 'twitterinfo.jar', "%s" % (url)], stdout=PIPE).communicate()
        if stdout.startswith('Data'):
            info = stdout.split()
            return info[1] , info[2]
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e


def get_face_book_user_data(url):
    stream = urllib.urlopen(url)
    data = stream.read()
    #print data
    #print
    json_data = json.loads(data)
    if json_data.has_key('error'):
        raise Exception('oauth_error for url %s' % (url))
    user_id = json_data["id"]
    if json_data.has_key("username"):
        user_name = json_data["username"]
    else:
        user_name = json_data["name"]
    email = ""
    if json_data.has_key("email"):
        email = json_data["email"]
    return user_id, user_name, email


def notify_facebook_user(url, access_token):
    try:
        user_id, user_name, email = get_face_book_user_data(url)
        print user_id, user_name
        try:
            post_to_facebook_wall(user_id, url, access_token)
            update_user_details(user_id, user_name, access_token)
        except Exception as ee:
            if len(email) > 0:
                print email
                update_user_details(user_id, user_name, access_token)
    except Exception as e:
        delete_user_details(access_token)
        print e
    

def notify_twitter_user(url):
    try:
        user_id, user_name = get_twitter_user_data(url)
        print user_id, user_name
        post_to_twitter_timeline(url)
        update_user_details(user_id, user_name, url)
    except Exception as e:
        #delete_user_details(url)
        print e



conn = mysql.connect(config.MYSQL_HOST_NAME, config.MYSQL_USER, config.MYSQL_USER_PASSWORD, config.MYSQL_DB)
select_cursor = conn.cursor()

select_cursor.execute("select * from authentication where used = 0")
for data in select_cursor.fetchall():
    access_token = data[0]
    company = data[1]
    used = data[2]
    if company == 'facebook':
        url = "https://graph.facebook.com/me?access_token=" + access_token
        notify_facebook_user(url, access_token)
    elif company == 'twitter':
        url = access_token
        notify_twitter_user(url)
select_cursor.close()
conn.close()
