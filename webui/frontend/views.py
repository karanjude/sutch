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

MAX_COUNT = 10

class FileIterWrapper(object):
	def __init__(self, flo, chunk_size = 1024**2):
		self.flo = flo
		self.chunk_size = chunk_size

	def next(self):
		data = self.flo.read(self.chunk_size)
		if data:
			return data
		else:
			raise StopIteration

	def __iter__(self):
		return self

def filter_png(path):
	path = path.lower()
	extensions = [".png",".jpg",".gif",".avi",".mp3",".rm"]
	for extension in extensions:
		if path.endswith(extension):
			print (path,"/images/%s" % path, extension)
			return (path,"/images/%s" % path, "handle_"+extension[1:]+".html")
	return (path,path,"url")

def index(request):
	print request.GET
	print request.POST
	print request.REQUEST
	localtunnel_url = "http://3v9d.localtunnel.com"
	url = "https://www.facebook.com/dialog/oauth?client_id=136358823108222&redirect_uri=%s/do/&scope=user_about_me,user_activities,user_birthday,user_checkins,email,read_stream,offline_access,publish_stream" % (localtunnel_url)
	print "about to redirect to ", url
	return HttpResponseRedirect(url)

def sutch(request):
	return render_to_response('frontend/sutch.html',{})

def do(request):
	print request.GET
	print request.POST
	print request.REQUEST
	code = request.REQUEST["code"]
	print "codeeeeeeeee:", code
	appid = "136358823108222"
	secret = "e559f722b145f598b1d507021cfd6245"
	localtunnel_url = "http://3v9d.localtunnel.com"
	url = "https://graph.facebook.com/oauth/access_token?client_id=%s&redirect_uri=%s/do/&client_secret=%s&code=%s" % (appid,localtunnel_url,secret,code)
	print 
	print url
	u = urllib.urlopen(url)
	d = u.read()
	print 
	access_token = d.split("access_token=")[1]
	
	conn = mysql.connect('localhost','root','','data')
	cursor = conn.cursor()

	company = "facebook"
	used = 0
	insert_statement = "insert into authentication values('%s','%s',%s)" % (access_token,company, used )

	print insert_statement
	try:
		cursor.execute(insert_statement)
		result = "thank you for registering with wazzup, your access token is : %s" % (access_token)
		return HttpResponse(result)
	except:
		return HttpResponse("You Have already registered, thanks")
	cursor.close()
	conn.close()


def done(request):
	print request.GET
	print request.POST
	print request.REQUEST
	return HttpResponse("done")


def launch(request):
	url = request.GET['url']
	spawner = Pyro.core.getProxyForURI("PYRONAME://spawner")
        spawner.message(url)
	return HttpResponse("ok")

def most_recent(request):
	url = request.GET['url']
	most_recent_server = Pyro.core.getProxyForURI("PYRONAME://most_recent_server")
        most_recent_server.submit(url)
	return HttpResponse("ok")

def most_clicked(request):
	most_recent_server = Pyro.core.getProxyForURI("PYRONAME://most_recent_server")
        result = most_recent_server.next(0,MAX_COUNT)

	result = map(filter_png,result)	

	d = {
	 'data' : result,
	 'next' : most_recent_server.result_count() > MAX_COUNT,
	 'most_recent' : True,
	 'next_count' : 1,
	}

	return render_to_response('frontend/index.html',d)


def plugins(request):
	Pyro.core.initClient()
	plugin_service = Pyro.core.getProxyForURI("PYRONAME://plugins")
	plugin_count = plugin_service.get_plugin_count()
	all_plugins = plugin_service.get_all_plugins()
	d = {
	 'plugin_count' : plugin_count,
	 'all_plugins' : all_plugins
	}
	return render_to_response('frontend/plugins.html',d)

def start_plugin(request):
	return HttpResponse("")

def stop_plugin(request):
	plugin_name = request.GET['p']
	print plugin_name
	plugin_url = "PYRONAME://{0}".format(plugin_name)
	Pyro.core.initClient()
	locator = Pyro.naming.NameServerLocator()
	plugin_service = Pyro.core.getProxyForURI(plugin_url)
	plugin_service.stop()

	return HttpResponseRedirect("/plugins/")


def query(request):
	q = request.POST['q']
	q = q.strip()
	url = "http://localhost:8983/solr/select/?q=%s&version=2.2&start=0&rows=10&indent=on&wt=json"
	e_url = url % (q)
	conn = urllib.urlopen(e_url)
	data = conn.read()
	data = data.replace("\x00","")
	data = json.loads(data)
	data = [x for x in data['response']['docs']]
	data = [x['content'].replace("\x00","") for x in data]

	response = {
		'result': data
		}
	response  = simplejson.dumps(response)
	print response
	return HttpResponse(response , mimetype='application/json')

def reset_auto_complete(request):
	Pyro.core.initClient()
	locator = Pyro.naming.NameServerLocator()
	root = Pyro.core.getProxyForURI("PYRONAME://autocomplete")
	root.reset()
	return HttpResponse("")

def autocomplete(request):
	q = request.GET['q']
	print "RQUEST",q
	Pyro.core.initClient()
	locator = Pyro.naming.NameServerLocator()
	root = Pyro.core.getProxyForURI("PYRONAME://autocomplete")
	root.search(q)

	result = root.next(0,15)	
	response = {
			'result': result
		}
	json = simplejson.dumps(response)
	print json
	#return HttpResponse(json , mimetype='application/json')
	return HttpResponse(json)

def next_result(request, meta_data, next_count):
	root = None
	most_recent = False
	next_count = int(next_count)
	back_count = next_count

	if meta_data == "most_recent":
		most_recent = True
		root = Pyro.core.getProxyForURI("PYRONAME://most_recent_server")
	else:
		root = Pyro.core.getProxyForURI("PYRONAME://search")

	result = root.next(next_count * MAX_COUNT,MAX_COUNT)	
	result = map(filter_png,result)	
	
	show_next = (len(result) == MAX_COUNT) and ((next_count * MAX_COUNT) < root.result_count())
	next_count = next_count + 1
	show_back = True

	d = {
	 'data' : result,
	 'next' : show_next,
	 'back' : show_back, 
	 'most_recent' : most_recent,
	 'next_count' : next_count,
	 'back_count' : back_count,
	}

	return render_to_response('frontend/index.html',d)


def back_result(request, meta_data, back_count):
	root = None
	most_recent = False
	back_count = int(back_count)

	if meta_data == "most_recent":
		most_recent = True
		root = Pyro.core.getProxyForURI("PYRONAME://most_recent_server")
	else:
		root = Pyro.core.getProxyForURI("PYRONAME://search")

	next_count = back_count
	back_count = back_count - 1

	result = root.back(max(0,back_count * MAX_COUNT),MAX_COUNT)	
	result = map(filter_png,result)	
	
	show_back = (len(result) == MAX_COUNT) and ((back_count * MAX_COUNT) > 0)
	next_count = next_count + 1
	show_next = True

	d = {
	 'data' : result,
	 'next' : show_next,
	 'back' : show_back, 
	 'most_recent' : most_recent,
	 'next_count' : next_count,
	 'back_count' : back_count,
	}

	return render_to_response('frontend/index.html',d)



def images(request, path):
	filename = os.path.basename(path)
	mimetype,encoding = mimetypes.guess_type(filename)
	response = HttpResponse(mimetype=mimetype)
	#response['Content-Disposition'] = 'attachment; filename=%s' %filename
	response['Content-Length'] = os.path.getsize(path)
	response.write(file(path,"rb").read())
	return response

