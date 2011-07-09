import sqlite3
import os

conn = sqlite3.connect("c:\\dev\\fulldata.db")
c = conn.cursor()
c.execute("""create table files(path text,parent text,accessed real, modified real, primary key(path))""")
c.execute("delete from files")
conn.commit()

def insert(r,f):
    try:
        d = os.path.join(r,f)
	s = os.stat(d)
	a = s.st_atime
	m = s.st_mtime
        c.execute("insert into files values(?,?,?,?)", (d,r,a,m))
    except:
        print "ERROR" ,r,f

def build_index(base_path):
    for r,d,f in os.walk(unicode(base_path), topdown=True):
        for dd in d:
            insert(r,dd)
        for ff in f:
            insert(r,ff)
    

if __name__=="__main__":
    base = "c:\\"
    insert(base,"")
    build_index(base)
    conn.commit()
    conn.close()
