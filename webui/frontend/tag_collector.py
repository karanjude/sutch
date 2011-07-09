import sqlite3

cc = sqlite3.connect("c:\\dev\\metadata.db")
c = cc.cursor()

tag_hash = {}

def add_tag_to_hash(tag):
    tags = tag.split(',')
    cleaned_up_tags = [t for t in tags if len(t) > 0]
    for t in cleaned_up_tags:
        count = 1
        if tag_hash.has_key(t):
            count = tag_hash[t]
            count = count + 1
        tag_hash[t] = count


def write_to_db():
    for k,v in tag_hash.iteritems():
        q = ur"insert into tags values('%s',%s)" % (k,v)
        c.execute(q)
    
def build_tags():
    c.execute("select * from file_tags")
    for r in c:
        add_tag_to_hash(r[1])
    write_to_db()

if __name__ == "__main__" :
    build_tags()
    cc.commit()
    cc.close()
    
 
