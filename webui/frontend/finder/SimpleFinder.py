import os

class SimpleFinder:
    def __init__(self, query,logger):
        self.query = query.split()
        self.result = []
        self.logger = logger


    def satisfies(self, to_test, against):
	result = [x for x in against if to_test.find(x) >= 0]
	return len(result) != 0
  
    def find(self, obj):
        if self.satisfies(obj.dir_path, self.query):
            self.result.append(obj.dir_path)
            self.logger.log(obj.dir_path)
            print "found...",obj.dir_path
        for file_name in obj.file_names:
            file_path = os.path.join(obj.dir_path,file_name)
            if self.satisfies(file_path, self.query):
                self.result.append(file_path)
                self.logger.log(file_path)
                print "found...",file_path
