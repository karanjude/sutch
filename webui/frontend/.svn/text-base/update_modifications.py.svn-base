import sqlite3
import os
import stat
import datetime

cc = sqlite3.connect("c:\\dev\\fulldata.db")
c = cc.cursor()

def was_modified(child_tuple):
    try:
        stored_modification_date = datetime.datetime.fromtimestamp(child_tuple[3])
        new_modification_date = datetime.datetime.fromtimestamp(os.stat(child_tuple[0]).st_mtime)
    except:
        return False
    return new_modification_date > stored_modification_date

def get_child_from_db(root):
    q = """select * from files where path ='%s'""" % root
    c.execute(q)
    result = [r for r in c]
    return result[0]

def get_children_from_db(root):
    q = """select * from files where parent = '%s'""" % root
    result = [x for x in c.execute(q)]
    return result

def children_from_db(root):
	r = [x[0] for x in get_children_from_db(root) if x[0] != root]
	return r

def children_from_file_system(root):
	result = []
	for r,d,f in os.walk(root, topdown=True):
		for dd in d:
			result.append(os.path.join(r,dd))
		for ff in f:
			result.append(os.path.join(r,ff))
		del d[:]
	return result

def get_differences(f):
	file_system_list = set(children_from_file_system(f))
	db_list = set(children_from_db(f))
	additions = list(file_system_list.difference(db_list))
	deletions = list(db_list.difference(file_system_list))
	return (additions,deletions)

def get_modifications(root):
    result = []
    if was_modified(get_child_from_db(root)):
        result.append(root)

    all_modifications = get_children_from_db(root)
    while len(all_modifications) > 0:
        child = all_modifications.pop(0)
        if child[0] == root:
            continue
        if was_modified(child):
            result.append(child[0])
            if stat.S_ISDIR(os.stat(child[0]).st_mode):
                all_modifications.extend(get_children_from_db(child[0]))
    return result

def parent(f):
    r = f[0:f.rfind(os.path.normcase('/'))]
    if r.find(os.path.normcase('/')) != -1:
              return r
    return r + os.path.normcase('/')

def update_modification(f):
    s = os.stat(f)
    a = s.st_atime
    m = s.st_mtime
    c.execute("""replace into files values(?,?,?,?)""",(f,parent(f),a,m))

def update_deletion(f):
    q = """delete from files where path = '%s'""" % f
    c.execute(q)

def update_addition(f):
    s = os.stat(f)
    a = s.st_atime
    m = s.st_mtime
    c.execute("""insert into files values(?,?,?,?)""",(f,parent(f),a,m))
                
def get_changes(f):
    additions, deletions = get_differences(f)
    for change in additions:
        print change , "was added"
        update_addition(change)
    for change in deletions:
        print change , "was deleted"
        update_deletion(change)

def print_modifications(root):
    result = get_modifications(root)
    for f in result:
        print f
        update_modification(f)
    for f in result:
        get_changes(f)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
if __name__ == "__main__":
    root = u"c:\\"
    print_modifications(root)
    cc.commit()
    cc.close()
