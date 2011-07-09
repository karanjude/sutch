"""Working example of the ReadDirectoryChanges API which will
 track changes made to a directory. Can either be run from a
 command-line, with a comma-separated list of paths to watch,
 or used as a module, either via the watch_path generator or
 via the Watcher threads, one thread per path.

Examples:
  watch_directory.py c:/temp,r:/images

or:
  import watch_directory
  for file_type, filename, action in watch_directory.watch_path ("c:/temp"):
    print filename, action

or:
  import watch_directory
  import Queue
  file_changes = Queue.Queue ()
  for pathname in ["c:/temp", "r:/goldent/temp"]:
    watch_directory.Watcher (pathname, file_changes)

  while 1:
    file_type, filename, action = file_changes.get ()
    print file_type, filename, action
    
(c) Tim Golden - mail at timgolden.me.uk 5th June 2009
Licensed under the (GPL-compatible) MIT License:
http://www.opensource.org/licenses/mit-license.php
"""
from __future__ import generators
import os
import sys
import Queue
import threading
import time
import datetime

import win32file
import win32con

ACTIONS = {
  1 : "Created",
  2 : "Deleted",
  3 : "Updated",
  4 : "Renamed to something",
  5 : "Renamed from something"
}

import os
import sqlite3

file_cc = sqlite3.connect("c:\\dev\\fulldata.db")
file_c = file_cc.cursor()

tags_cc = sqlite3.connect("c:\\dev\\metadata.db")
tags_c = tags_cc.cursor()

tag_hash = {}


def build_tag_hash():
	tags_c.execute(ur"select * from tags")
	for r in tags_c:
		tag_hash[r[0]] = r[1]

def clean_up_tag(tag):
	result = tag.split(' ')
	if len(result) == 1:
		result = tag.split('_')
	if len(result) == 1:
		result = tag.split('-')
	return result


def tag_it(file_path, add=True):
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
		parts.extend(clean_up_tag(part.lower()))
	for i in set(parts):
		count = 1
		if tag_hash.has_key(i):
			count = tag_hash[i]
			if add:
				count = count + 1
			else:
				count = count - 1
				if i == file_name:
					count = 0
		tag_hash[i] = count
		if count >= 0:
			tags_c.execute(ur"replace into tags values(?,?)",(i,count))
			print "REPLACE INTO QUERY EXECUTED"
			tags_cc.commit()
		else:
			tags_c.execute(ur"delete from tags where tag=(?)",(i))
	

def parent(f):
	r = f[0:f.rfind(os.path.normcase('/'))]
	if r.find(os.path.normcase('/')) != -1:
		return r
	return r + os.path.normcase('/')

def insert_file(f):
	st = os.stat(f)
        a_time = st.st_atime
        m_time = st.st_mtime
        file_c.execute(ur"insert into files values(?,?,?,?)" ,(f,parent(f),a_time,m_time))
	file_cc.commit()
	tag_it(f)
	print "INSERT QUERY EXECUTED"

def remove_file(self,f):
	is_dir = f.endswith(os.path.normcase('/'))
	q = ur"delete from files where path='%s'" % f
        file_c.execute((q ,()))
        if is_dir:
		file_c.execute(ur"delete from files where parent = (?)" , (f))
	tag_it(f,False)

def add_file(f):
         is_dir = os.path.isdir(f)
         insert_file(f)
         if is_dir:
		for r,d,f in os.walk(f):
			for dd in d:
				dir_path = os.path.join(r,dd)
				insert_file(dir_path)
                        for ff in f:
				file_path = os.path.join(r,ff)
                                insert_file(file_path)

def remove_file(file_path):
	pass

def remove_folder(file_path):
	pass

def watch_path (path_to_watch, include_subdirectories=False):
  FILE_LIST_DIRECTORY = 0x0001
  hDir = win32file.CreateFile (
    path_to_watch,
    FILE_LIST_DIRECTORY,
    win32con.FILE_SHARE_READ | win32con.FILE_SHARE_WRITE,
    None,
    win32con.OPEN_EXISTING,
    win32con.FILE_FLAG_BACKUP_SEMANTICS,
    None
  )

  while 1:
    results = win32file.ReadDirectoryChangesW (
      hDir,
      1024,
      include_subdirectories,
       win32con.FILE_NOTIFY_CHANGE_FILE_NAME | 
       win32con.FILE_NOTIFY_CHANGE_DIR_NAME |
       win32con.FILE_NOTIFY_CHANGE_ATTRIBUTES |
       win32con.FILE_NOTIFY_CHANGE_SIZE |
       win32con.FILE_NOTIFY_CHANGE_LAST_WRITE |
       win32con.FILE_NOTIFY_CHANGE_LAST_ACCESS |
       win32con.FILE_NOTIFY_CHANGE_SECURITY,
      None,
      None
    )
    for action, file in results:
      full_filename = os.path.join (path_to_watch, file)
      if not os.path.exists (full_filename):
        file_type = "<deleted>"
      elif os.path.isdir (full_filename):
        file_type = 'folder'
      else:
        file_type = 'file'
      yield (file_type, full_filename, ACTIONS.get (action, "Unknown"))

class Watcher (threading.Thread):

  def __init__ (self, path_to_watch, results_queue, **kwds):
    threading.Thread.__init__ (self, **kwds)
    self.setDaemon (1)
    self.path_to_watch = path_to_watch
    self.results_queue = results_queue
    self.start ()

  def run (self):
    for result in watch_path (self.path_to_watch, True):
      self.results_queue.put (result)

if __name__ == '__main__':
  """If run from the command line, use the thread-based
   routine to watch the current directory (default) or
   a list of directories specified on the command-line
   separated by commas, eg

   watch_directory.py c:/temp,c:/
  """
  PATH_TO_WATCH = ["."]

  build_tag_hash()
  try: 
	path_to_watch = sys.argv[1].split (",") or PATH_TO_WATCH
  except: 
	path_to_watch = PATH_TO_WATCH
  path_to_watch = [os.path.abspath (p) for p in path_to_watch]

  print "Watching %s at %s" % (", ".join (path_to_watch), time.asctime ())
  files_changed = Queue.Queue ()
  
  for p in path_to_watch:
    Watcher (p, files_changed)

  while 1:
    try:
      file_type, filename, action = files_changed.get_nowait ()
      print file_type, filename, action	
      if action == "Created":
	add_file(filename)

      if action == "Deleted":
	remove_file(filename)
    except Queue.Empty:
	pass
    except Exception, x:
	print x
    time.sleep (1)

  file_cc.commit()
  file_cc.close()
  tags_cc.commit()
  tags_cc.close()

