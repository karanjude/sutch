import Pyro.core
import Pyro.naming
import finder.SimpleFinder
import finder.AllFileCounter

import os
import sys
import re

from threading import Thread
import threading 
import sqlite3

from Queue import Queue

class RootEntity(Pyro.core.ObjBase, Thread):
    def __init__(self, daemon):
        Pyro.core.ObjBase.__init__(self)
	Thread.__init__(self)
	self.result_set = []
        self.request_queue = Queue()
	
    def run(self):
	conn = sqlite3.connect(":memory:")
	c = conn.cursor()
	c.execute("attach database 'c:\\dev\\fulldata.db' as db")
	while True:
            print "waiting for request"
            command, query, result = self.request_queue.get()
            print "result processing begun"
            if command == "null":
                break
            c.execute(query)
            print "dispatching results"
            for r in c:
                result.put(r)
            result.put("null")
	c.execute("detach database db")
        conn.close()
            
    def result_count(self):
	return len(self.result_set)
     
    def fetch_remote_results(self, offset,count):
	print "fetching remote results"
	counter = 0
	for i in self.process_query_result(offset, count):
		counter = counter + 1
		self.result_set.append(i)
		if counter >= count+1:
			break
   
    def back(self, starting_index, count):
	ans = []
	for i in range(starting_index,starting_index + count):
		ans.append(self.result_set[i])
	return ans

    def fetch_local_results(self, starting_index, count):
	print "fetching local results ", starting_index
	ans = []
	upper_bound = starting_index + count
	if upper_bound > len(self.result_set):
		upper_bound = len(self.result_set)
	for i in range(starting_index,upper_bound):
		ans.append(self.result_set[i])
	return ans

    def next(self, starting_index, count):
	ans = []
	if len(self.result_set) < (starting_index + count):
		self.fetch_remote_results(starting_index,count)
	ans.extend(self.fetch_local_results(starting_index,count))
	return ans

    def process_query_result(self, offset, count):
	result = Queue()
	self.request_queue.put((self.command,self.make_query(self.q, offset, count + 1),result))
        while True:
            print "waiting for result"
            r = result.get()
            print "result received"
            if r == "null":
                break
            yield r[0]
            
    def make_query(self,q, offset = 0, count = 10):
	words = q.split()
	result = ur"select * from files where "
	result += ur" and ".join([u" path like '%%%s%%'" for word in words]) 
	result += ur" limit %s,%s"
	result_set = []
	result_set.extend([w for w in words])
	result_set.append(offset)
	result_set.append(count)
	query = result % tuple(result_set) 
        print query
	return query

    def search(self, q , command="execute"):
	self.q = q
	self.result_set = []
        self.command = command

    def shutdown(self):
	self.search("","null")


def startServer():
    Pyro.core.initServer()
    locator = Pyro.naming.NameServerLocator()
    ns = locator.getNS()
    daemon = Pyro.core.Daemon()
    daemon.useNameServer(ns)

    server = RootEntity(daemon)
    daemon.connect(server, 'search')
    server.start()
	   
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
