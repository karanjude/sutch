import Pyro.core
import Pyro.naming

import os
import sys
import subprocess
import threading
from threading import Thread

class RootEntity(Pyro.core.ObjBase):
    def __init__(self, daemon):
        Pyro.core.ObjBase.__init__(self)
        self.result = []

    def has_next(self):
        return len(self.result) > 0

    def get_next(self):
        r = self.result.pop(0)
        return r

    def unlog(self):
        self.result = []

    def log(self, message):
        print "LOG: " + message
        self.result.append(message)
        


def startServer():
    Pyro.core.initServer()
    locator = Pyro.naming.NameServerLocator()
    ns = locator.getNS()
    daemon = Pyro.core.Daemon()
    daemon.useNameServer(ns)

    server = RootEntity(daemon)
    daemon.connect(server, 'logger')
        
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
