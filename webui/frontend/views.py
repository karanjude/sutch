# Create your views here.
from django.http import HttpResponse, HttpResponseRedirect
from django.template import Context, loader
from django.shortcuts import render_to_response
from django.utils import simplejson

import os
import io
import urllib
import json
import MySQLdb as mysql
import httplib
import oauth.oauth as oauth
import md5

MAX_COUNT = 10
FACEBOOK_CALLBACK_URL = "http://107.20.249.171"

# settings for the local test consumer
SERVER = 'api.twitter.com'
PORT = 80

# twitter credentials
CONSUMER_KEY = '3BEPD0jb9zEAMMJi8guGw'
CONSUMER_SECRET = '8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4'

REQUEST_TOKEN_URL = 'https://api.twitter.com/oauth/request_token'
ACCESS_TOKEN_URL = 'https://api.twitter.com/oauth/access_token'
AUTHORIZATION_URL = 'https://photos.example.net/authorize'
CALLBACK_URL = 'http://4n8h.localtunnel.com'


# facebook credentials
FACEBOOK_APP_ID = "136358823108222"
FACEBOOK_APP_SECRET = "e559f722b145f598b1d507021cfd6245"

#solr config
SOLR_REQUEST_URL = "http://localhost:8983/solr/select/?q=%s&version=2.2&start=%s&rows=10&indent=on&wt=json"

#mysql config
MYSQL_HOST_NAME = 'localhost'
MYSQL_USER = 'root'
MYSQL_PASSWORD = ''
MYSQL_DB = 'data'

def twitter(request):
	server = SERVER
        port = PORT
        request_token_url = REQUEST_TOKEN_URL
        access_token_url = ACCESS_TOKEN_URL
        authorization_url = AUTHORIZATION_URL
        connection = httplib.HTTPSConnection("%s" % (server))
        connection.set_debuglevel(1)

	consumer = oauth.OAuthConsumer(CONSUMER_KEY, CONSUMER_SECRET)
	signature_method_hmac_sha1 = oauth.OAuthSignatureMethod_HMAC_SHA1()
	oauth_request = oauth.OAuthRequest.from_consumer_and_token(consumer, callback=CALLBACK_URL, http_url=request_token_url)
	
	oauth_request.sign_request(signature_method_hmac_sha1, consumer, None)

	print 'REQUEST (via headers)'
	print 'parameters: %s' % str(oauth_request.parameters)

        connection.request(oauth_request.http_method, request_token_url, headers=oauth_request.to_header()) 
        response = connection.getresponse()
        data = response.read()
        print data
        print
        token =  oauth.OAuthToken.from_string(data)
	
	print 'GOT'
	print 'key: %s' % str(token.key)
	print 'secret: %s' % str(token.secret)
	print 'callback confirmed? %s' % str(token.callback_confirmed)
	url = 'http://api.twitter.com/oauth/authorize?oauth_token=' + token.key
	print url
	
	file_name = "/tmp/sessions/%s" % (token.key)
	f = open(file_name,"w")
	f.write(token.to_string())
	f.close()

	response = HttpResponseRedirect(url)
	return response


def facebook(request):
	print request.GET
	print request.POST
	print request.REQUEST
	callback_url = FACEBOOK_CALLBACK_URL
	url = "https://www.facebook.com/dialog/oauth?client_id=136358823108222&redirect_uri=%s/do/&scope=user_about_me,user_activities,user_birthday,user_checkins,email,read_stream,offline_access,publish_stream" % (callback_url)
	print "about to redirect to ", url
	return HttpResponseRedirect(url)

def indextwitter(request):
	verifier = request.REQUEST['oauth_verifier']
	oauth_token = request.REQUEST['oauth_token']

	print "session_data" , request.session.keys()

	file_name = "/tmp/sessions/%s" % (oauth_token)
	f = open(file_name)
	request_token =  f.readline()
	f.close()


	if request_token is None or  len(request_token) == 0:
		return HttpResponse("error")

	token = oauth.OAuthToken.from_string(request_token)
	token.key = oauth_token

	server = SERVER
        port = PORT
        request_token_url = REQUEST_TOKEN_URL
        access_token_url = ACCESS_TOKEN_URL
        authorization_url = AUTHORIZATION_URL
        connection = httplib.HTTPSConnection("%s" % (server))
        connection.set_debuglevel(1)

	signature_method_hmac_sha1 = oauth.OAuthSignatureMethod_HMAC_SHA1()

	consumer = oauth.OAuthConsumer(CONSUMER_KEY, CONSUMER_SECRET)
	oauth_request = oauth.OAuthRequest.from_consumer_and_token(consumer, token=token, verifier=verifier, http_url=access_token_url)
	signature_method_hmac_sha1 = oauth.OAuthSignatureMethod_HMAC_SHA1()
	oauth_request.sign_request(signature_method_hmac_sha1, consumer, token)
	print 'REQUEST (via headers)'
	print 'parameters: %s' % str(oauth_request.parameters)

        connection.request(oauth_request.http_method, access_token_url, headers=oauth_request.to_header()) 
        response = connection.getresponse()
	data = response.read()
	print "data is :", data
        r = oauth.OAuthToken.from_string(data)
	r = str(r)

	m = {}
	for y in r.split('&'):
		rr = y.split('=')
		m[rr[0]] = rr[1]

	url = 'http://api.twitter.com/1/?consumer_key=%s&consumer_secret=%s&oauth_key=%s&oauth_secret=%s' % (CONSUMER_KEY, CONSUMER_SECRET, m['oauth_token'], m['oauth_token_secret'])

	conn = mysql.connect(MYSQL_HOST_NAME,MYSQL_USER,MYSQL_PASSWORD,MYSQL_DB)
	cursor = conn.cursor()


	company = "twitter"
        used = 0
        user_id = None
        posted = 0
        user_name = None
        insert_statement = "insert into authentication values('%s','%s',%s,NULL,%s,NULL)" % (url, company, used,  posted)

	print insert_statement
	try:
		cursor.execute(insert_statement)
		r = "Thanks for registering with us, you will be able to search your data soon"
	except Exception as e:
		r = "You have already registered with us"
		print e

	cursor.close()
	conn.close()

	return render_to_response('frontend/sutch.html',{'info':r})


def sutch(request):
	return render_to_response('frontend/sutch.html',{})

def do(request):
	#print request.GET
	#print request.POST
	#print request.REQUEST

	code = request.REQUEST["code"]
	callback_url = FACEBOOK_CALLBACK_URL
	url = "https://graph.facebook.com/oauth/access_token?client_id=%s&redirect_uri=%s/do/&client_secret=%s&code=%s" % (FACEBOOK_APP_ID,callback_url,FACEBOOK_APP_SECRET,code)

	#print 
	#print url

	u = urllib.urlopen(url)
	d = u.read()

	#print 
	access_token = d.split("access_token=")[1]
	
	conn = mysql.connect(MYSQL_HOST_NAME,MYSQL_USER,MYSQL_PASSWORD,MYSQL_DB)
	cursor = conn.cursor()

	company = "facebook"
        used = 0
        user_id = None
        posted = 0
        user_name = None
        insert_statement = "insert into authentication values('%s','%s',%s,NULL,%s,NULL)" % (access_token,company, used,  posted)

	print insert_statement
	r = None
	try:
		cursor.execute(insert_statement)
		r = "Thanks for registering with us, you will be able to search your data soon"
	except Exception as e:
		r = "You have already registered with us"
		print e

	cursor.close()
	conn.close()
	return render_to_response('frontend/sutch.html',{'info':r})


def done(request):
	print request.GET
	print request.POST
	print request.REQUEST
	return HttpResponse("done")

def query(request):
	q = request.POST['q']
	c = request.POST['c']
	q = q.strip()
	c = c.strip()

	url = SOLR_REQUEST_URL
	e_url = url % (q,c)
	conn = urllib.urlopen(e_url)
	data = conn.read()
	data = data.replace("\x00","")
	data = json.loads(data)
	data = [x for x in data['response']['docs']]
	data = [x['content'].replace("\x00","").replace("\u0000","") for x in data]

	response = {
		'result': data
		}
	response  = simplejson.dumps(response)
	print response
	return HttpResponse(response , mimetype='application/json')


