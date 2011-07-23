#!/bin/bash

# Nutch crawl

export NUTCH_HOME=./runtime/deploy
export HADOOP_HOME=~/Data/study/information-retrieval-and-web-search-engines/hadoop/hadoop-0.20.203.0/

# depth in the web exploration
n=1
# number of selected urls for fetching
maxUrls=50000
# solr server
solrUrl=http://0.0.0.0:8983
                                                                                                                                                                                                                                                                                                                                                                      
for (( i = 1 ; i <= $n ; i++ ))
do

log=`ls -rt runtime/local/logs/log* | tail -1`

# Generate

cat seeds/urls

echo "injecting urls"
`python inject.py`
echo "created new seeds urls"

cat seeds/urls

echo "injecting new urls"
$NUTCH_HOME/bin/nutch crawl seeds
echo "injecting new urls done"

echo "generating new urls"
$NUTCH_HOME/bin/nutch generate 
echo "generate done"

#$batchId=`sed -n 's|.*batch id: \(.*\)|\1|p' < $log`
#$batchId="-all"
#echo `cat $log | grep batch | perl -e '$t= <STDIN>;$t =~ "id:(.*)";$r=$1;$r=~ s/^\s+//;print $r;'`
#batchId=`cat $log | grep batch | perl -e '$t= <STDIN>;$t =~ "id:(.*)";$r=$1;$r=~ s/^\s+//;print $r;'`
batchId="-all"
echo "The batch id that was generated $batchId"

# rename log file by appending the batch id
log2=$log$batchId
mv $log $log2
log=$log2

# Fetch
echo "starting fetch";
$NUTCH_HOME/bin/nutch fetch $batchId 
echo "fetch done"

# Parse
echo "starting parse"
$NUTCH_HOME/bin/nutch parse $batchId 
echo "parse done"

# Update
echo "starting db update"
$NUTCH_HOME/bin/nutch updatedb 
echo "update db done"

echo "truncation entries from seed url"
`python mark_as_used.py`
echo "" > seed/urls

cat seeds\urls

# Index
#$NUTCH_HOME/bin/nutch solrindex $solrUrl $batchId >> $log

done
