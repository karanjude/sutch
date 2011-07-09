import os
import time
import datetime

root = ur"c:\\"

for r,d,f in os.walk(root, topdown=False):
	parent_timestamp = os.stat(r).st_mtime
	latest_timestamp = parent_timestamp
	for dd in d:
		dir_path = os.path.join(r,dd)
		timestamp = os.stat(dir_path).st_mtime
		if timestamp > latest_timestamp:
			latest_timestamp = timestamp
	for ff in f:
		file_path = os.path.join(r,ff)
		timestamp = os.stat(file_path).st_mtime
		if timestamp > latest_timestamp:
			latest_timestamp = timestamp
	if latest_timestamp > parent_timestamp:
		atime = time.mktime(datetime.datetime.now().timetuple())
		mtime = time.mktime(datetime.datetime.fromtimestamp(latest_timestamp).timetuple())
		os.utime(r,(atime,mtime))
