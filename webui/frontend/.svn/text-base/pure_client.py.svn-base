import Pyro.core
import Pyro.naming
import threading
from threading import Thread

class Listener(Pyro.core.ObjBase):
	def __init__(self):
		Pyro.core.ObjBase.__init__(self)
	def callback(self, message):
		print 'GOT CALLBACK: ',message


class Client:
    def start(self):
        Pyro.core.initServer()
        Pyro.core.initClient()
        daemon = Pyro.core.Daemon()
	locator = Pyro.naming.NameServerLocator()
	NS = locator.getNS()
	daemon.useNameServer(NS)
	listener = Listener()
	daemon.connect(listener)

        server = Pyro.core.getProxyForURI("PYRONAME://server")
        server.register(listener.getProxy())
        path = raw_input("Enter path:")
        server.process(path)

if __name__ == "__main__":
    c = Client()
    c.start()
