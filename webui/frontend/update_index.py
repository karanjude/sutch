import sqlite3
import threading
from threading import Thread, Lock
import os
from Queue import Queue
import datetime
import re

cc = sqlite3.connect("c:\\dev\\fulldata.db")
c = cc.cursor()
q = Queue(10)
tags_queue = Queue()
sql_queue = Queue()
lock = Lock()


class Tagger(Thread):

        def __init__(self, tq):
                Thread.__init__(self)
                self.tq = tq
                self.tag_hash = {}

        def build_tag_hash(self):
                self.child_c.execute(ur"select * from tags")
                for r in self.child_c:
                        self.tag_hash[r[0]] = r[1]

        def clean_up_tag(self,tag):
                result = tag.split(' ')
                if len(result) == 1:
                        result = tag.split('_')
                if len(result) == 1:
                        result = tag.split('-')
                return result


        def tag_it(self, file_path):
                path_parts = file_path.split(os.path.normpath('/'))
                parts = []
                part_count = len(path_parts)
                last_part = path_parts[part_count-1]
                dot_index = last_part.rfind('.')
                is_file = dot_index != -1
                if is_file:
                        file_type = last_part[(dot_index + 1):]
                        file_name = last_part[:dot_index]
                        path_parts[part_count-1] = file_type
                        parts.append(file_name)
                for part in path_parts[1:]:
                        parts.extend(self.clean_up_tag(part.lower()))
                for i in set(parts):
                        count = 1
                        if self.tag_hash.has_key(i):
                                count = self.tag_hash[i]
                                count = count + 1
                        self.tag_hash[i] = count
                self.tq.task_done()


        def update_db(self):
                for k,v in self.tag_hash.iteritems():
                        self.child_c.execute("replace into tags values(?,?)", (k,v))


        def run(self):
                self.child_cc = sqlite3.connect(ur"c:\\dev\\metadata.db")
                self.child_c = self.child_cc.cursor()
                self.build_tag_hash()
                while True:
                        message = self.tq.get()
                        if message == "exit":
                                self.tq.task_done()
                                break
                        else:
                            self.tag_it(message)

                self.update_db()
                self.child_cc.commit()
                self.child_cc.close()
                        

class DiffFinder(Thread):

        def __init__(self, q, tq, sq,lock):
                Thread.__init__(self)
                self.q = q
                self.tq = tq
                self.sq = sq
                self.lock = lock
                

        def get_dir_children_from_file_system(self, dir_name):
                result = []
                for r,d,f in os.walk(dir_name):
                        for dd in d:
                                dir_path = os.path.join(r,dd)
                                result.append(dir_path)
                        for ff in f:
                                file_path = os.path.join(r,ff)
                                result.append(file_path)
                        del d[:]
                return result

        def get_dir_children_from_db(self, parent_name):
            sql = ur"select path from files where parent='%s'" % (parent_name)
            result = []
            try:
                    self.child_c.execute(sql)
                    result = [r[0] for r in self.child_c if r[0] != parent_name]
            except:
                    pass
            return result

        def has_modified(self, parent_dir):
                self.child_c.execute(ur"select * from files where path=(?)",(parent_dir,))
                file_record = self.child_c.fetchone()
                if file_record is None:
                        return True
                time_from_db = datetime.datetime.fromtimestamp(file_record[3])
                file_system_timestamp = os.stat(parent_dir).st_mtime
                time_from_file_system = datetime.datetime.fromtimestamp(file_system_timestamp)
                is_modified = time_from_file_system > time_from_db
                if is_modified:
                        self.sq.put((ur"update files set modified=(?) where path=(?)" , (file_system_timestamp, parent_dir)))
                return is_modified

        def parent(self,f):
                r = f[0:f.rfind(os.path.normcase('/'))]
                if r.find(os.path.normcase('/')) != -1:
                        return r
                return r + os.path.normcase('/')

        def insert_file(self,f):
                st = os.stat(f)
                a_time = st.st_atime
                m_time = st.st_mtime
                self.sq.put((ur"insert into files values(?,?,?,?)" , (f,self.parent(f),a_time,m_time)))
                self.tq.put(f)

        def add_file(self, f):
                v = f
                is_dir = os.path.isdir(f)
                self.insert_file(f)
                if is_dir:
                        for r,d,f in os.walk(f):
                                for dd in d:
                                        dir_path = os.path.join(r,dd)
                                        self.insert_file(dir_path)
                                for ff in f:
                                        file_path = os.path.join(r,ff)
                                        self.insert_file(file_path)
                self.lock.acquire()
                print "file added : ",v
                self.lock.release()

        def remove_file(self,f):
                is_dir = f.endswith(os.path.normcase('/'))
                q = ur"delete from files where path='%s'" % f
                self.sq.put((q ,()))
                if is_dir:
                        self.sq.put((ur"delete from files where parent = (?)" , (f)))
                self.lock.acquire()
                print "file removed : ",f
                self.lock.release()

        def is_present(self, file_path):
                exists = os.path.exists(file_path)
                if not exists:
                        self.remove_file(file_path)
                return exists
                
        def find_diff(self,parent_dir):
            if self.is_present(parent_dir) and self.has_modified(parent_dir):
                    from_db = set(self.get_dir_children_from_db(parent_dir))
                    from_file_system = set(self.get_dir_children_from_file_system(parent_dir))
                    to_be_added = from_file_system.difference(from_db)
                    to_be_removed = from_db.difference(from_file_system)
                    for f in to_be_added:
                            self.add_file(f)
                    for f in to_be_removed:
                            self.remove_file(f)
            self.q.task_done()

        def run(self):
            self.child_cc = sqlite3.connect("c:\\dev\\fulldata.db")
            self.child_c = self.child_cc.cursor()
            while True:
                    message = self.q.get()
                    if message == "exit":
                            self.q.task_done()
                            self.child_cc.close()
                            break
                    else:
                            self.find_diff(message)
            
            
                
def collect_all_parent_dirs():
    sql = ur"select distinct parent from files"
    c.execute(sql)


if __name__ == "__main__":
    collect_all_parent_dirs()
    num_of_threads = 10
    
    tagger = Tagger(tags_queue)
    tagger.setDaemon(True)
    tagger.start()

    for i in range(num_of_threads):
            t = DiffFinder(q, tags_queue, sql_queue, lock)
            t.setDaemon(True)
            t.start()

    for r in c:
        q.put(r[0])
        q.join()

    for i in range(num_of_threads):
            q.put("exit")
            q.join()

    tags_queue.put("exit")
    tags_queue.join()

    while not sql_queue.empty():
            q = sql_queue.get()
            try:
	    	print q[0],q[1]
            	c.execute(q[0],q[1])
            	sql_queue.task_done()
            except Exception,e:
                    print "executing .. ",q,e
                    sql_queue.task_done()
            
    
    cc.commit()
    cc.close()
