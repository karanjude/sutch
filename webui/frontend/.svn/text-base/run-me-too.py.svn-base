import sys
import sqlite3
import threading
from threading import Thread
from Queue import Queue
import os

task_queue = Queue()

class Tagger(Thread):

        def __init__(self, tq):
                Thread.__init__(self)
                self.tag_hash = {}
		self.tq = tq

        def build_tag_hash(self):
                self.child_c.execute(ur"select * from tags")
                for r in self.child_c:
                        self.tag_hash[r[0]] = r[1]

	def parent(self,f):
		r = f[0:f.rfind(os.path.normcase('/'))]
		if r.find(os.path.normcase('/')) != -1:
			return r
		return r + os.path.normcase('/')


        def clean_up_tag(self,tag):
                result = tag.split(' ')
                if len(result) == 1:
                        result = tag.split('_')
                if len(result) == 1:
                        result = tag.split('-')
                return result


        def tag_it(self, file_path, add=True):
                path_parts = file_path.split(os.path.normpath('/'))
                parts = []
                part_count = len(path_parts)
                last_part = path_parts[part_count-1]
                dot_index = last_part.rfind('.')
                is_file = dot_index != -1
		file_name = ""
                if is_file:
                        file_type = last_part[(dot_index + 1):]
                        file_name = last_part
                        path_parts[part_count-1] = file_type
                        parts.append(file_name)
                for part in path_parts[1:]:
                        parts.extend(self.clean_up_tag(part.lower()))
                for i in set(parts):
                        count = 1
                        if self.tag_hash.has_key(i):
				if add:
					count = count + 1
				else:
					count = count - 1
					if i == file_name:
						count = 0
			self.tag_hash[i] = count
			if count >= 0:
				self.child_c.execute(ur"replace into tags values(?,?)",(i,count))
				print "REPLACE INTO QUERY EXECUTED",i,count
			else:
				self.child_c.execute(ur"delete from tags where tag=(?)",(i))
			self.child_cc.commit()
                self.tq.task_done()


        def run(self):
                self.child_cc = sqlite3.connect(ur"c:\\dev\\metadata.db")
                self.child_c = self.child_cc.cursor()
                self.build_tag_hash()
		self.files_cc = sqlite3.connect(ur"c:\\dev\\fulldata.db")
		self.files_c = self.files_cc.cursor()
                while True:
                        message = self.tq.get()
                        if message == "exit":
                                self.tq.task_done()
                                break
                        else:
			    try:
				if message[0] == 'C':
					print "RECEIVED MESSAGE", message
					self.add_file(message[1:])
					self.tag_it(message)

			    	if message[0] == 'R':
					self.remove_file(message[1:])
                            		self.tag_it(message,False)
			    except Exception,e:
				print e
				

                self.child_cc.commit()
                self.child_cc.close()


	def insert_file(self,f):
		st = os.stat(f)
		a_time = st.st_atime
		m_time = st.st_mtime
		self.files_c.execute(ur"insert into files values(?,?,?,?)" ,(f,self.parent(f),a_time,m_time))
		self.files_cc.commit()
		print "INSERT QUERY EXECUTED"

	def remove_file(self,f):
		is_dir = f.endswith(os.path.normcase('/'))
		q = ur"delete from files where path='%s'" % f
		self.files_c.execute((q ,()))
        	if is_dir:
			self.files_c.execute(ur"delete from files where parent = (?)" , (f))
		self.files_cc.commit()

	def add_file(self,f):
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



tagger = Tagger(task_queue)
tagger.setDaemon(True)
tagger.start()

while True:
    line = sys.stdin.readline()
    if line:
        #print "LINE:", line
	try:
		line = unicode(line.strip())
		if line[0] == 'C':
			print "LINE:",line
	except Exception,e:
		print e
    task_queue.put(line)
    sys.stdout.flush()

