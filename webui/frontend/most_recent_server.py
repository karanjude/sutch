import Pyro.core
import Pyro.naming
import finder.SimpleFinder
import finder.AllFileCounter

import os
import sys

from threading import Thread
import sqlite3

class RootEntity(Pyro.core.ObjBase):
    def __init__(self, daemon):
        Pyro.core.ObjBase.__init__(self)
	self.most_recent_clicks = []
	self.most_clicked_hash = {}
	self.cc = sqlite3.connect("c:\\dev\\metadata.db")
	self.c = self.cc.cursor()
	self.build_click_hash()
	self.update_click_list()

    def build_click_hash(self):
	self.c.execute("""select * from most_clicked""")
	for r in self.c:
		self.most_clicked_hash[r[0]] = r[1]

    def update_click_list(self):
	for k in self.most_clicked_hash.iterkeys():
		self.most_recent_clicks.append(k)

    def result_count(self):
	return len(self.most_recent_clicks)

    def back(self, starting_index, count):
	ans = []
	for i in range(starting_index,starting_index + count):
		ans.append(self.most_recent_clicks[i])
	return ans

    def next(self, starting_index, count):
	ans = []
	upper_bound = starting_index + count
	if upper_bound > len(self.most_recent_clicks):
		upper_bound = len(self.most_recent_clicks)

	for i in range(starting_index,upper_bound):
		ans.append(self.most_recent_clicks[i])
	return ans

    def submit(self, url):
	if self.most_clicked_hash.has_key(url):
		count = self.most_clicked_hash[url]
		count = count + 1
		self.most_clicked_hash[url] = count
		print "%s updating url"
	else:
		self.most_clicked_hash[url] = 0
		self.most_recent_clicks.insert(0, url)
		print "%s added" % url

    def shutdown(self):
	for url,count in self.most_clicked_hash.iteritems():
		self.c.execute("""replace into most_clicked values(?,?) """ , (url,count))
		print "INSERTING....",url
	self.cc.commit()
	self.cc.close()
	print "updated db"

def startServer():
    Pyro.core.initServer()
    locator = Pyro.naming.NameServerLocator()
    ns = locator.getNS()
    daemon = Pyro.core.Daemon()
    daemon.useNameServer(ns)

    server = RootEntity(daemon)
    daemon.connect(server, 'most_recent_server')
        
    try:
        daemon.requestLoop()
    except Exception , e:
        print str(e)
    finally:
	server.shutdown()
        daemon.shutdown(True)
	


if __name__ == "__main__":
    Pyro.config.PYRO_TRACELEVEL = 3
    Pyro.config.PYRO_LOGFILE='log_file'
    Pyro.config.PYRO_MAXCONNECTIONS = 1000
    startServer()
