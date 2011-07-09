import sqlite3
import os

cc = sqlite3.connect("c:\\dev\\metadata.db")
c = cc.cursor()

def add_tag(file_path, tag_string):
    q = ur"insert into file_tags values('%s','%s')" % (file_path, tag_string)
    try:
        c.execute(q)
    except:
        print q
    #print q
    
def clean_up_tag(tag):
	result = tag.split(' ')
	if len(result) == 1:
		result = tag.split('_')
	if len(result) == 1:
		result = tag.split('-')
	return result

def tag_it(file_path):
    path_parts = file_path.split(os.path.normpath('/'))
    parts = []
    part_count = len(path_parts)
    last_part = path_parts[part_count-1]
    dot_index = last_part.rfind('.')
    is_file = dot_index != -1
    if is_file:
        file_type = last_part[(dot_index + 1):]
        path_parts[part_count-1] = file_type
    for part in path_parts[1:]:
        parts.extend(clean_up_tag(part.lower()))
    add_tag(file_path,",".join(tuple(set(parts))))

def tag_all_files(root):
    for r,d,f in os.walk(root, topdown=True):
        for dd in d:
            dir_path = os.path.join(r,dd)
            tag_it(dir_path)
        for ff in f:
            file_path = os.path.join(r,ff)
            tag_it(file_path)

            

if __name__ == "__main__":
    root = ur"c:\\"
    tag_all_files(root)
    cc.commit()
    cc.close()
