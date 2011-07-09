import os
import subprocess
import time

from multiprocessing import Process
import sys
import multiprocessing

def do_stuff():
    p = os.system("c:\\dev\\desk_search\\frontend\\desksearch\\frontend\\pyro\\Pyro-3.9.1\\bin\\pyro-ns.cmd")

def do_stuff1():
    p = os.system("c:\\Python26\\python.exe c:\\dev\\desk_search\\frontend\\desksearch\\frontend\\search_server.py")

def do_stuff2():
    p = os.system("c:\\Python26\\python.exe c:\\dev\\desk_search\\frontend\\desksearch\\frontend\\auto_complete_server.py")

def do_stuff3():
    p = os.system("c:\\Python26\\python.exe c:\\dev\\desk_search\\simple_server.py")

def do_stuff4():
    p = os.system("c:\\Python26\\python.exe c:\\dev\\desk_search\\frontend\\desksearch\\manage.py runserver")

def do_stuff5():
    p = os.system("java -jar c:\\dev\\desk_search\\frontend\\desksearch\\frontend\\run-me.jar | python c:\\dev\\desk_search\\frontend\\desksearch\\frontend\\run-me-too.py")

if __name__ == "__main__":
    p1 = Process(target=do_stuff, args=())
    p1.start()
    time.sleep(10)
    p2 = Process(target=do_stuff1, args=())
    p2.start()
    p3 = Process(target=do_stuff2, args=())
    p3.start()
    p4 = Process(target=do_stuff3, args=())
    p4.start()
    p5 = Process(target=do_stuff4, args=())
    p5.start()
    p6 = Process(target=do_stuff5, args=())
    p6.start()
 
    os.startfile("http://localhost:8000/query/",'open')

    try:
        p1.join()
    except:
        print "received exception"
    finally:
        p1.terminate()
        p2.terminate()
        p3.terminate()
        p4.terminate()
	p5.terminate()
	p6.terminate()
    
        
