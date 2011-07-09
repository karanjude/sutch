import Pyro.core
import Pyro.naming

import os
import sys
import subprocess
import threading
from threading import Thread

class DirectoryEntity(Pyro.core.ObjBase):
    def __init__(self, daemon, name, dir_path):
        Pyro.core.ObjBase.__init__(self)
        self.name = name
        self.daemon = daemon
        self.children = []
        self.child_count = 0
        self.child_names = []
        self.dir_path = dir_path
        self.file_names = []

    def register_child(self, child_name, child_path):
        child = DirectoryEntity(self.daemon, child_name, child_path)
        self.daemon.connect(child, child_name)
        self.children.append(child)
        
    def add_child(self, root_dir, child_dir_name):
        child_name = self.name + "_c" + str(self.child_count)
        self.child_count = self.child_count + 1
        child_dir_path = os.path.join(root_dir, child_dir_name)
        self.register_child(child_name, child_dir_path)
        self.child_names.append(child_name)

    def _process(self):
        for root, dirs, files in os.walk(self.dir_path, topdown = True):
            print "visited : ", root
            for dir_name in dirs:
                self.add_child(root, dir_name)
            for file_name in files:
                self.file_names.append(file_name)
		file_dir_path = os.path.join(root,file_name)
            del dirs[:]

    def process(self):
        all_children = [self]
        while len(all_children) > 0:
            child = all_children.pop(0)
            child._process()
            all_children.extend(child.children)
        Pyro.config.PYRO_MOBILE_CODE=1

    def _search(self, query, result):
        #print "searching " + self.dir_path
        for child in self.children:
            #print "Searching child " + child.dir_path + "for " + query
            if child.dir_path.find(query) >= 0:
                result.append(child.dir_path)
            for file_name in child.file_names:
                file_path = os.path.join(child.dir_path,file_name)
                if file_path.find(query) >= 0:
                    result.append(file_path)
                    print "match found : " + file_path
            child._search(query, result)

    def search(self, query):
        result = []
        self._search(query, result)
        return "\n".join(result)

    def _find(self, finder):
        finder.find(self)
        for c in self.children:
            c._find(finder)
        return finder

    def resolve_query(self, finder):
        f = self._find(finder)
        logger = Pyro.core.getProxyForURI("PYRONAME://logger")
        logger.log("NULL")
	return f

    def find(self, finder):
        #t = Thread(target=self.resolve_query, args=(finder,))
        #t.start()
	return self.resolve_query(finder)
        

class RootEntity(Pyro.core.ObjBase):
    def __init__(self, daemon,conn):
        Pyro.core.ObjBase.__init__(self)
        self.daemon = daemon
        self.client = None

    def register(self, client):
        self.client = client

    def process(self, dir_path):
        print "Server processing started...."
        child_name = "p"
        child = DirectoryEntity(self.daemon, child_name, dir_path)
        self.daemon.connect(child, child_name)
        locator = Pyro.naming.NameServerLocator()
        ns = locator.getNS()
        uri = "PYRONAME://" + child_name
        obj = Pyro.core.getProxyForURI(uri)
        obj.process()
        


def startServer():
    Pyro.core.initServer()
    locator = Pyro.naming.NameServerLocator()
    ns = locator.getNS()
    daemon = Pyro.core.Daemon()
    daemon.useNameServer(ns)

    server = RootEntity(daemon,conn)
    daemon.connect(server, 'server')
        
    try:
        daemon.requestLoop()
    except Exception , e:
        print str(e)
    finally:
        daemon.shutdown(True)


if __name__ == "__main__":
    Pyro.config.PYRO_TRACELEVEL = 3
    Pyro.config.PYRO_LOGFILE='log_file'
    Pyro.config.PYRO_MAXCONNECTIONS = 1000
    startServer()
