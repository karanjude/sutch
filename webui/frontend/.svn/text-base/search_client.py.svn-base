import Pyro.core
import Pyro.naming
import finder.SimpleFinder
import finder.AllFileCounter

from threading import Thread

def search(q):
    root = Pyro.core.getProxyForURI("PYRONAME://p")
    logger = Pyro.core.getProxyForURI("PYRONAME://logger")
    f = finder.SimpleFinder.SimpleFinder(q,logger)
    root.find(f)

def show_results():
    result_collector = Pyro.core.getProxyForURI("PYRONAME://logger")
    result_collector.unlog()
    count = 0
    r = ""
    while r != "NULL":
        while not result_collector.has_next():
            pass
        r = result_collector.get_next()
        if r == "NULL":
            if count == 0:
                print "\n RESULT NOT FOUND"
        else:
            print "\nRESULT : ", r
            count = count + 1
    
class SearchClient:
    def start(self):
        Pyro.core.initClient()
        locator = Pyro.naming.NameServerLocator()
        ns = locator.getNS()
        f = None
        while True:
            q = raw_input("Enter query : ")
            t = Thread(target=search,args=(q,))
            t.start()
            show_results()

if __name__ == "__main__":
    c = SearchClient()
    c.start()
