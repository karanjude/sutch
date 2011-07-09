import Pyro.core
import Pyro.naming
import finder.SimpleFinder
import finder.AllFileCounter

import os
import sys

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
	self.count = 0
	
    def run(self):
	conn = sqlite3.connect("c:\\dev\\metadata.db")
	c = conn.cursor()
	while True:
            print "waiting for request"
            command, query, result = self.request_queue.get()
            print "result processing begun"
            if command == "null":
		result.put(command)
                continue
	    if command == "shutdown":
		result.put(command)
		break
	    print "executing query", query
            c.execute(query)
            print "dispatching results"
            for r in c:
		print "putting",r
		self.count = self.count + 1
		print "COUNT", self.count
                result.put(r)
        conn.close()
            
    def result_count(self):
	return len(self.result_set)
     
    def fetch_remote_results(self, offset,count):
	print "fetching remote results"
	counter = 0
	for i in self.process_query_result(offset, count):
		counter = counter + 1
		if i == "null":
			break
		self.result_set.append(i)
		print "adding to result", i,counter
		if counter >= count-1:
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
	self.result_set = []
	if len(self.result_set) < (starting_index + count):
		self.fetch_remote_results(starting_index,count)
		print "RESULT SET",self.result_set
	ans.extend(self.fetch_local_results(starting_index,count))
	return ans

    def process_query_result(self, offset, count):
	result = Queue()
	prefix = False
	self.request_queue.put((self.command,self.make_query(self.q, offset,count/2,True),result))
 	self.request_queue.put((self.command,self.make_query(self.q, offset, count/2,prefix),result))
	self.request_queue.put(("null","null",result))
	while True:
            print "wating for result"
            r = result.get()
            print "getting ",r
            if r == "null":
                yield "null"
	    else:
		yield r[0]
	    if r == "shutdown":
		break
            
    def make_query(self,q, offset = 0, count = 10, prefix = True):
	words = q.split()
	result = ur"select * from tags where "
	if prefix:
		result += ur" or ".join([u" tag like '%s'" for word in words]) 
	else:
		result += ur" and ".join([u" tag like '%%%s%%'" for word in words]) 
	result += ur" limit %s,%s"
	result_set = []
	result_set.extend(words)
	result_set.append(offset)
	result_set.append(count)
	query = result % tuple(result_set) 
	print query
	return query

    def reset(self):
	pass

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
    daemon.connect(server, 'autocomplete')
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
