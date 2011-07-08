<?xml version="1.0" encoding="UTF-8" ?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

<!-- 
     For more details about configurations options that may appear in
     this file, see http://wiki.apache.org/solr/SolrConfigXml. 
-->
<config>
  <!-- In all configuration below, a prefix of "solr." for class names
       is an alias that causes solr to search appropriate packages,
       including org.apache.solr.(search|update|request|core|analysis)

       You may also specify a fully qualified Java classname if you
       have your own custom plugins.
    -->

  <!-- Set this to 'false' if you want solr to continue working after
       it has encountered an severe configuration error.  In a
       production environment, you may want solr to keep working even
       if one handler is mis-configured.

       You may also set this to false using by setting the system
       property:

         -Dsolr.abortOnConfigurationError=false
    -->
  <abortOnConfigurationError>${solr.abortOnConfigurationError:true}</abortOnConfigurationError>
  
  <!-- Controls what version of Lucene various components of Solr
       adhere to.  Generally, you want to use the latest version to
       get all bug fixes and improvements. It is highly recommended
       that you fully re-index after changing this setting as it can
       affect both how text is indexed and queried.
    -->
  <luceneMatchVersion>LUCENE_31</luceneMatchVersion>

  <!-- lib directives can be used to instruct Solr to load an Jars
       identified and use them to resolve any "plugins" specified in
       your solrconfig.xml or schema.xml (ie: Analyzers, Request
       Handlers, etc...).

       All directories and paths are resolved relative to the
       instanceDir.

       If a "./lib" directory exists in your instanceDir, all files
       found in it are included as if you had used the following
       syntax...
       
              <lib dir="./lib" />
    -->
  <!-- A dir option by itself adds any files found in the directory to
       the classpath, this is useful for including all jars in a
       directory.
    -->
  <lib dir="../../contrib/extraction/lib" />
  <!-- When a regex is specified in addition to a directory, only the
       files in that directory which completely match the regex
       (anchored on both ends) will be included.
    -->
  <lib dir="../../dist/" regex="apache-solr-cell-\d.*\.jar" />
  <lib dir="../../dist/" regex="apache-solr-clustering-\d.*\.jar" />
  <lib dir="../../dist/" regex="apache-solr-dataimporthandler-\d.*\.jar" />

  <!-- If a dir option (with or without a regex) is used and nothing
       is found that matches, it will be ignored
    -->
  <lib dir="../../contrib/clustering/lib/" />
  <lib dir="/total/crap/dir/ignored" /> 
  <!-- an exact path can be used to specify a specific file.  This
       will cause a serious error to be logged if it can't be loaded.
    -->
  <!--
  <lib path="../a-jar-that-does-not-exist.jar" /> 
  -->
  
  <!-- Data Directory

       Used to specify an alternate directory to hold all index data
       other than the default ./data under the Solr home.  If
       replication is in use, this should match the replication
       configuration.
    -->
  <dataDir>${solr.data.dir:}</dataDir>


  <!-- The DirectoryFactory to use for indexes.
       
       solr.StandardDirectoryFactory, the default, is filesystem
       based.  solr.RAMDirectoryFactory is memory based, not
       persistent, and doesn't work with replication.
    -->
  <directoryFactory name="DirectoryFactory" 
                    class="${solr.directoryFactory:solr.StandardDirectoryFactory}"/>


  <!-- Index Defaults

       Values here affect all index writers and act as a default
       unless overridden.

       WARNING: See also the <mainIndex> section below for parameters
       that overfor Solr's main Lucene index.
    -->
  <indexDefaults>

    <useCompoundFile>false</useCompoundFile>

    <mergeFactor>10</mergeFactor>
    <!-- Sets the amount of RAM that may be used by Lucene indexing
         for buffering added documents and deletions before they are
         flushed to the Directory.  -->
    <ramBufferSizeMB>32</ramBufferSizeMB>
    <!-- If both ramBufferSizeMB and maxBufferedDocs is set, then
         Lucene will flush based on whichever limit is hit first.  
      -->
    <!-- <maxBufferedDocs>1000</maxBufferedDocs> -->

    <maxFieldLength>10000</maxFieldLength>
    <writeLockTimeout>1000</writeLockTimeout>
    <commitLockTimeout>10000</commitLockTimeout>

    <!-- Expert: Merge Policy 

         The Merge Policy in Lucene controls how merging is handled by
         Lucene.  The default in 2.3 is the LogByteSizeMergePolicy,
         previous versions used LogDocMergePolicy.
         
         LogByteSizeMergePolicy chooses segments to merge based on
         their size.  The Lucene 2.2 default, LogDocMergePolicy chose
         when to merge based on number of documents
         
         Other implementations of MergePolicy must have a no-argument
         constructor
      -->
    <!--
       <mergePolicy class="org.apache.lucene.index.LogByteSizeMergePolicy"/>
       -->

    <!-- Expert: Merge Scheduler

         The Merge Scheduler in Lucene controls how merges are
         performed.  The ConcurrentMergeScheduler (Lucene 2.3 default)
         can perform merges in the background using separate threads.
         The SerialMergeScheduler (Lucene 2.2 default) does not.
     -->
    <!-- 
       <mergeScheduler class="org.apache.lucene.index.ConcurrentMergeScheduler"/>
       -->
	  
    <!-- LockFactory 

         This option specifies which Lucene LockFactory implementation
         to use.
      
         single = SingleInstanceLockFactory - suggested for a
                  read-only index or when there is no possibility of
                  another process trying to modify the index.
         native = NativeFSLockFactory - uses OS native file locking.
                  Do not use when multiple solr webapps in the same
                  JVM are attempting to share a single index.
         simple = SimpleFSLockFactory  - uses a plain file for locking

         (For backwards compatibility with Solr 1.2, 'simple' is the
         default if not specified.)

         More details on the nuances of each LockFactory...
         http://wiki.apache.org/lucene-java/AvailableLockFactories
    -->
    <lockType>native</lockType>

    <!-- Expert: Controls how often Lucene loads terms into memory
         Default is 128 and is likely good for most everyone.
      -->
    <!-- <termIndexInterval>256</termIndexInterval> -->
  </indexDefaults>

  <!-- Main Index

       Values here override the values in the <indexDefaults> section
       for the main on disk index.
    -->
  <mainIndex>

    <useCompoundFile>false</useCompoundFile>
    <ramBufferSizeMB>32</ramBufferSizeMB>
    <mergeFactor>10</mergeFactor>

    <!-- Unlock On Startup

         If true, unlock any held write or commit locks on startup.
         This defeats the locking mechanism that allows multiple
         processes to safely access a lucene index, and should be used
         with care.

         This is not needed if lock type is 'none' or 'single'
     -->
    <unlockOnStartup>false</unlockOnStartup>
    
    <!-- If true, IndexReaders will be reopened (often more efficient)
         instead of closed and then opened.
      -->
    <reopenReaders>true</reopenReaders>

    <!-- Commit Deletion Policy

         Custom deletion policies can specified here. The class must
         implement org.apache.lucene.index.IndexDeletionPolicy.

         http://lucene.apache.org/java/2_9_1/api/all/org/apache/lucene/index/IndexDeletionPolicy.html

         The standard Solr IndexDeletionPolicy implementation supports
         deleting index commit points on number of commits, age of
         commit point and optimized status.
         
         The latest commit point should always be preserved regardless
         of the criteria.
    -->
    <deletionPolicy class="solr.SolrDeletionPolicy">
      <!-- The number of commit points to be kept -->
      <str name="maxCommitsToKeep">1</str>
      <!-- The number of optimized commit points to be kept -->
      <str name="maxOptimizedCommitsToKeep">0</str>
      <!--
          Delete all commit points once they have reached the given age.
          Supports DateMathParser syntax e.g.
        -->
      <!--
         <str name="maxCommitAge">30MINUTES</str>
         <str name="maxCommitAge">1DAY</str>
      -->
    </deletionPolicy>

    <!-- Lucene Infostream
       
         To aid in advanced debugging, Lucene provides an "InfoStream"
         of detailed information when indexing.

         Setting The value to true will instruct the underlying Lucene
         IndexWriter to write it's debugging info the specified file
      -->
     <infoStream file="INFOSTREAM.txt">false</infoStream> 

  </mainIndex>

  <!-- JMX
       
       This example enables JMX if and only if an existing MBeanServer
       is found, use this if you want to configure JMX through JVM
       parameters. Remove this to disable exposing Solr configuration
       and statistics to JMX.

       For more details see http://wiki.apache.org/solr/SolrJmx
    -->
  <jmx />
  <!-- If you want to connect to a particular server, specify the
       agentId 
    -->
  <!-- <jmx agentId="myAgent" /> -->
  <!-- If you want to start a new MBeanServer, specify the serviceUrl -->
  <!-- <jmx serviceUrl="service:jmx:rmi:///jndi/rmi://localhost:9999/solr"/>
    -->

  <!-- The default high-performance update handler -->
  <updateHandler class="solr.DirectUpdateHandler2">

    <!-- AutoCommit

         Perform a <commit/> automatically under certain conditions.
         Instead of enabling autoCommit, consider using "commitWithin"
         when adding documents. 

         http://wiki.apache.org/solr/UpdateXmlMessages

         maxDocs - Maximum number of documents to add since the last
                   commit before automaticly triggering a new commit.

         maxTime - Maximum amount of time that is allowed to pass
                   since a document was added before automaticly
                   triggering a new commit. 
      -->
    <!--
       <autoCommit> 
         <maxDocs>10000</maxDocs>
         <maxTime>1000</maxTime> 
       </autoCommit>
      -->

    <!-- Update Related Event Listeners
         
         Various IndexWriter realted events can trigger Listeners to
         take actions.

         postCommit - fired after every commit or optimize command
         postOptimize - fired after every optimize command
      -->
    <!-- The RunExecutableListener executes an external command from a
         hook such as postCommit or postOptimize.
         
         exe - the name of the executable to run
         dir - dir to use as the current working directory. (default=".")
         wait - the calling thread waits until the executable returns. 
                (default="true")
         args - the arguments to pass to the program.  (default is none)
         env - environment variables to set.  (default is none)
      -->
    <!-- This example shows how RunExecutableListener could be used
         with the script based replication...
         http://wiki.apache.org/solr/CollectionDistribution
      -->
    <!--
       <listener event="postCommit" class="solr.RunExecutableListener">
         <str name="exe">solr/bin/snapshooter</str>
         <str name="dir">.</str>
         <bool name="wait">true</bool>
         <arr name="args"> <str>arg1</str> <str>arg2</str> </arr>
         <arr name="env"> <str>MYVAR=val1</str> </arr>
       </listener>
      -->
  </updateHandler>
  
  <!-- IndexReaderFactory

       Use the following format to specify a custom IndexReaderFactory,
       which allows for alternate IndexReader implementations.

       ** Experimental Feature **

       Please note - Using a custom IndexReaderFactory may prevent
       certain other features from working. The API to
       IndexReaderFactory may change without warning or may even be
       removed from future releases if the problems cannot be
       resolved.


       ** Features that may not work with custom IndexReaderFactory **

       The ReplicationHandler assumes a disk-resident index. Using a
       custom IndexReader implementation may cause incompatibility
       with ReplicationHandler and may cause replication to not work
       correctly. See SOLR-1366 for details.

    -->
  <!--
  <indexReaderFactory name="IndexReaderFactory" class="package.class">
    <str name="someArg">Some Value</str>
  </indexReaderFactory >
  -->
  <!-- By explicitly declaring the Factory, the termIndexDivisor can
       be specified.
    -->
  <!--
     <indexReaderFactory name="IndexReaderFactory" 
                         class="solr.StandardIndexReaderFactory">
       <int name="setTermIndexDivisor">12</int>
     </indexReaderFactory >
    -->


  <query>
    <!-- Max Boolean Clauses

         Maximum number of clauses in each BooleanQuery,  an exception
         is thrown if exceeded.

         ** WARNING **
         
         This option actually modifies a global Lucene property that
         will affect all SolrCores.  If multiple solrconfig.xml files
         disagree on this property, the value at any given moment will
         be based on the last SolrCore to be initialized.
         
      -->
    <maxBooleanClauses>1024</maxBooleanClauses>


    <!-- Solr Internal Query Caches

         There are two implementations of cache available for Solr,
         LRUCache, based on a synchronized LinkedHashMap, and
         FastLRUCache, based on a ConcurrentHashMap.  

         FastLRUCache has faster gets and slower puts in single
         threaded operation and thus is generally faster than LRUCache
         when the hit ratio of the cache is high (> 75%), and may be
         faster under other scenarios on multi-cpu systems.
    -->

    <!-- Filter Cache

         Cache used by SolrIndexSearcher for filters (DocSets),
         unordered sets of *all* documents that match a query.  When a
         new searcher is opened, its caches may be prepopulated or
         "autowarmed" using data from caches in the old searcher.
         autowarmCount is the number of items to prepopulate.  For
         LRUCache, the autowarmed items will be the most recently
         accessed items.

         Parameters:
           class - the SolrCache implementation LRUCache or
               (LRUCache or FastLRUCache)
           size - the maximum number of entries in the cache
           initialSize - the initial capacity (number of entries) of
               the cache.  (see java.util.HashMap)
           autowarmCount - the number of entries to prepopulate from
               and old cache.  
      -->
    <filterCache class="solr.FastLRUCache"
                 size="512"
                 initialSize="512"
                 autowarmCount="0"/>

    <!-- Query Result Cache
         
         Caches results of searches - ordered lists of document ids
         (DocList) based on a query, a sort, and the range of documents requested.  
      -->
    <queryResultCache class="solr.LRUCache"
                     size="512"
                     initialSize="512"
                     autowarmCount="0"/>
   
    <!-- Document Cache

         Caches Lucene Document objects (the stored fields for each
         document).  Since Lucene internal document ids are transient,
         this cache will not be autowarmed.  
      -->
    <documentCache class="solr.LRUCache"
                   size="512"
                   initialSize="512"
                   autowarmCount="0"/>
    
    <!-- Field Value Cache
         
         Cache used to hold field values that are quickly accessible
         by document id.  The fieldValueCache is created by default
         even if not configured here.
      -->
    <!--
       <fieldValueCache class="solr.FastLRUCache"
                        size="512"
                        autowarmCount="128"
                        showItems="32" />
      -->

    <!-- Custom Cache

         Example of a generic cache.  These caches may be accessed by
         name through SolrIndexSearcher.getCache(),cacheLookup(), and
         cacheInsert().  The purpose is to enable easy caching of
         user/application level data.  The regenerator argument should
         be specified as an implementation of solr.CacheRegenerator 
         if autowarming is desired.  
      -->
    <!--
       <cache name="myUserCache"
              class="solr.LRUCache"
              size="4096"
              initialSize="1024"
              autowarmCount="1024"
              regenerator="com.mycompany.MyRegenerator"
              />
      -->


    <!-- Lazy Field Loading

         If true, stored fields that are not requested will be loaded
         lazily.  This can result in a significant speed improvement
         if the usual case is to not load all stored fields,
         especially if the skipped fields are large compressed text
         fields.
    -->
    <enableLazyFieldLoading>true</enableLazyFieldLoading>

   <!-- Use Filter For Sorted Query

        A possible optimization that attempts to use a filter to
        satisfy a search.  If the requested sort does not include
        score, then the filterCache will be checked for a filter
        matching the query. If found, the filter will be used as the
        source of document ids, and then the sort will be applied to
        that.

        For most situations, this will not be useful unless you
        frequently get the same search repeatedly with differnet sort
        options, and none of them ever use "score"
     -->
   <!--
      <useFilterForSortedQuery>true</useFilterForSortedQuery>
     -->

   <!-- Result Window Size

        An optimization for use with the queryResultCache.  When a search
        is requested, a superset of the requested number of document ids
        are collected.  For example, if a search for a particular query
        requests matching documents 10 through 19, and queryWindowSize is 50,
        then documents 0 through 49 will be collected and cached.  Any further
        requests in that range can be satisfied via the cache.  
     -->
   <queryResultWindowSize>20</queryResultWindowSize>

   <!-- Maximum number of documents to cache for any entry in the
        queryResultCache. 
     -->
   <queryResultMaxDocsCached>200</queryResultMaxDocsCached>

   <!-- Query Related Event Listeners

        Various IndexSearcher related events can trigger Listeners to
        take actions.

        newSearcher - fired whenever a new searcher is being prepared
        and there is a current searcher handling requests (aka
        registered).  It can be used to prime certain caches to
        prevent long request times for certain requests.

        firstSearcher - fired whenever a new searcher is being
        prepared but there is no current registered searcher to handle
        requests or to gain autowarming data from.

        
     -->
    <!-- QuerySenderListener takes an array of NamedList and executes a
         local query request for each NamedList in sequence. 
      -->
    <listener event="newSearcher" class="solr.QuerySenderListener">
      <arr name="queries">
        <!--
           <lst><str name="q">solr</str><str name="sort">price asc</str></lst>
           <lst><str name="q">rocks</str><str name="sort">weight asc</str></lst>
          -->
      </arr>
    </listener>
    <listener event="firstSearcher" class="solr.QuerySenderListener">
      <arr name="queries">
        <lst>
          <str name="q">static firstSearcher warming in solrconfig.xml</str>
        </lst>
      </arr>
    </listener>

    <!-- Use Cold Searcher

         If a search request comes in and there is no current
         registered searcher, then immediately register the still
         warming searcher and use it.  If "false" then all requests
         will block until the first searcher is done warming.
      -->
    <useColdSearcher>false</useColdSearcher>

    <!-- Max Warming Searchers
         
         Maximum number of searchers that may be warming in the
         background concurrently.  An error is returned if this limit
         is exceeded.

         Recommend values of 1-2 for read-only slaves, higher for
         masters w/o cache warming.
      -->
    <maxWarmingSearchers>2</maxWarmingSearchers>

  </query>


  <!-- Request Dispatcher

       This section contains instructions for how the SolrDispatchFilter
       should behave when processing requests for this SolrCore.

       handleSelect affects the behavior of requests such as /select?qt=XXX

       handleSelect="true" will cause the SolrDispatchFilter to process
       the request and will result in consistent error handling and
       formating for all types of requests.

       handleSelect="false" will cause the SolrDispatchFilter to
       ignore "/select" requests and fallback to using the legacy
       SolrServlet and it's Solr 1.1 style error formatting
    -->
  <requestDispatcher handleSelect="true" >
    <!-- Request Parsing

         These settings indicate how Solr Requests may be parsed, and
         what restrictions may be placed on the ContentStreams from
         those requests

         enableRemoteStreaming - enables use of the stream.file
         and stream.url paramaters for specifying remote streams.

         multipartUploadLimitInKB - specifies the max size of
         Multipart File Uploads that Solr will alow in a Request.
         
         *** WARNING ***
         The settings below authorize Solr to fetch remote files, You
         should make sure your system has some authentication before
         using enableRemoteStreaming="true"

      --> 
    <requestParsers enableRemoteStreaming="true" 
                    multipartUploadLimitInKB="2048000" />

    <!-- HTTP Caching

         Set HTTP caching related parameters (for proxy caches and clients).

         The options below instruct Solr not to output any HTTP Caching
         related headers
      -->
    <httpCaching never304="true" />
    <!-- If you include a <cacheControl> directive, it will be used to
         generate a Cache-Control header (as well as an Expires header
         if the value contains "max-age=")
         
         By default, no Cache-Control header is generated.
         
         You can use the <cacheControl> option even if you have set
         never304="true"
      -->
    <!--
       <httpCaching never304="true" >
         <cacheControl>max-age=30, public</cacheControl> 
       </httpCaching>
      -->
    <!-- To enable Solr to responde with automaticly generated HTTP
         Caching headers, and to response to Cache Validation requests
         correctly, set the value of never304="false"
         
         This will cause Solr to generate Last-Modified and ETag
         headers based on the properties of the Index.

         The following options can also be specified to affect the
         values of these headers...

         lastModFrom - the default value is "openTime" which means the
         Last-Modified value (and validation against If-Modified-Since
         requests) will all be relative to when the current Searcher
         was opened.  You can change it to lastModFrom="dirLastMod" if
         you want the value to exactly corrispond to when the physical
         index was last modified.

         etagSeed="..." is an option you can change to force the ETag
         header (and validation against If-None-Match requests) to be
         differnet even if the index has not changed (ie: when making
         significant changes to your config file)

         (lastModifiedFrom and etagSeed are both ignored if you use
         the never304="true" option)
      -->
    <!--
       <httpCaching lastModifiedFrom="openTime"
                    etagSeed="Solr">
         <cacheControl>max-age=30, public</cacheControl> 
       </httpCaching>
      -->
  </requestDispatcher>

  <!-- Request Handlers 

       http://wiki.apache.org/solr/SolrRequestHandler

       incoming queries will be dispatched to the correct handler
       based on the path or the qt (query type) param.

       Names starting with a '/' are accessed with the a path equal to
       the registered name.  Names without a leading '/' are accessed
       with: http://host/app/[core/]select?qt=name

       If a /select request is processed with out a qt param
       specified, the requestHandler that declares default="true" will
       be used.
       
       If a Request Handler is declared with startup="lazy", then it will
       not be initialized until the first request that uses it.

    -->
  <!-- SearchHandler

       http://wiki.apache.org/solr/SearchHandler

       For processing Search Queries, the primary Request Handler
       provided with Solr is "SearchHandler" It delegates to a sequent
       of SearchComponents (see below) and supports distributed
       queries across multiple shards
    -->
  <requestHandler name="search" class="solr.SearchHandler" default="true">
    <!-- default values for query parameters can be specified, these
         will be overridden by parameters in the request
      -->
     <lst name="defaults">
       <str name="echoParams">explicit</str>
       <int name="rows">10</int>
     </lst>
    <!-- In addition to defaults, "appends" params can be specified
         to identify values which should be appended to the list of
         multi-val params from the query (or the existing "defaults").
      -->
    <!-- In this example, the param "fq=instock:true" would be appended to
         any query time fq params the user may specify, as a mechanism for
         partitioning the index, independent of any user selected filtering
         that may also be desired (perhaps as a result of faceted searching).

         NOTE: there is *absolutely* nothing a client can do to prevent these
         "appends" values from being used, so don't use this mechanism
         unless you are sure you always want it.
      -->
    <!--
       <lst name="appends">
         <str name="fq">inStock:true</str>
       </lst>
      -->
    <!-- "invariants" are a way of letting the Solr maintainer lock down
         the options available to Solr clients.  Any params values
         specified here are used regardless of what values may be specified
         in either the query, the "defaults", or the "appends" params.

         In this example, the facet.field and facet.query params would
         be fixed, limiting the facets clients can use.  Faceting is
         not turned on by default - but if the client does specify
         facet=true in the request, these are the only facets they
         will be able to see counts for; regardless of what other
         facet.field or facet.query params they may specify.

         NOTE: there is *absolutely* nothing a client can do to prevent these
         "invariants" values from being used, so don't use this mechanism
         unless you are sure you always want it.
      -->
    <!--
       <lst name="invariants">
         <str name="facet.field">cat</str>
         <str name="facet.field">manu_exact</str>
         <str name="facet.query">price:[* TO 500]</str>
         <str name="facet.query">price:[500 TO *]</str>
       </lst>
      -->
    <!-- If the default list of SearchComponents is not desired, that
         list can either be overridden completely, or components can be
         prepended or appended to the default list.  (see below)
      -->
    <!--
       <arr name="components">
         <str>nameOfCustomComponent1</str>
         <str>nameOfCustomComponent2</str>
       </arr>
      -->
    </requestHandler>

  <!-- A Robust Example

       This example SearchHandler declaration shows off usage of the
       SearchHandler with many defaults declared

       Note that multiple instances of hte same Request Handler
       (SearchHandler) can be registered multiple times with different
       names (and different init parameters)
    -->
  <requestHandler name="/browse" class="solr.SearchHandler">
     <lst name="defaults">
       <str name="echoParams">explicit</str>

       <!-- VelocityResponseWriter settings -->
       <str name="wt">velocity</str>

       <str name="v.template">browse</str>
       <str name="v.layout">layout</str>
       <str name="title">Solritas</str>

       <str name="defType">edismax</str>
       <str name="q.alt">*:*</str>
       <str name="rows">10</str>
       <str name="fl">*,score</str>
       <str name="mlt.qf">
         text^0.5 features^1.0 name^1.2 sku^1.5 id^10.0 manu^1.1 cat^1.4
       </str>
       <str name="mlt.fl">text,features,name,sku,id,manu,cat</str>
       <int name="mlt.count">3</int>

       <str name="qf">
          text^0.5 features^1.0 name^1.2 sku^1.5 id^10.0 manu^1.1 cat^1.4
       </str>

       <str name="facet">on</str>
       <str name="facet.field">cat</str>
       <str name="facet.field">manu_exact</str>
       <str name="facet.query">ipod</str>
       <str name="facet.query">GB</str>
       <str name="facet.mincount">1</str>
       <str name="facet.pivot">cat,inStock</str>
       <str name="facet.range">price</str>
       <int name="f.price.facet.range.start">0</int>
       <int name="f.price.facet.range.end">600</int>
       <int name="f.price.facet.range.gap">50</int>
       <str name="f.price.facet.range.other">after</str>
       <str name="facet.range">manufacturedate_dt</str>
       <str name="f.manufacturedate_dt.facet.range.start">NOW/YEAR-10YEARS</str>
       <str name="f.manufacturedate_dt.facet.range.end">NOW</str>
       <str name="f.manufacturedate_dt.facet.range.gap">+1YEAR</str>
       <str name="f.manufacturedate_dt.facet.range.other">before</str>
       <str name="f.manufacturedate_dt.facet.range.other">after</str>


       <!-- Highlighting defaults -->
       <str name="hl">on</str>
       <str name="hl.fl">text features name</str>
       <str name="f.name.hl.fragsize">0</str>
       <str name="f.name.hl.alternateField">name</str>
     </lst>
     <arr name="last-components">
       <str>spellcheck</str>
     </arr>
     <!--
     <str name="url-scheme">httpx</str>
     -->
  </requestHandler>

  <!-- XML Update Request Handler.  
       
       http://wiki.apache.org/solr/UpdateXmlMessages

       The canonical Request Handler for Modifying the Index through
       commands specified using XML.

       Note: Since solr1.1 requestHandlers requires a valid content
       type header if posted in the body. For example, curl now
       requires: -H 'Content-type:text/xml; charset=utf-8'
    -->
  <requestHandler name="/update" 
                  class="solr.XmlUpdateRequestHandler">
    <!-- See below for information on defining 
         updateRequestProcessorChains that can be used by name 
         on each Update Request
      -->
    <!--
       <lst name="defaults">
         <str name="update.processor">dedupe</str>
       </lst>
       -->
    </requestHandler>
  <!-- Binary Update Request Handler
       http://wiki.apache.org/solr/javabin
    -->
  <requestHandler name="/update/javabin" 
                  class="solr.BinaryUpdateRequestHandler" />

  <!-- CSV Update Request Handler
       http://wiki.apache.org/solr/UpdateCSV
    -->
  <requestHandler name="/update/csv" 
                  class="solr.CSVRequestHandler" 
                  startup="lazy" />

  <!-- JSON Update Request Handler
       http://wiki.apache.org/solr/UpdateJSON
    -->
  <requestHandler name="/update/json" 
                  class="solr.JsonUpdateRequestHandler" 
                  startup="lazy" />

  <!-- Solr Cell Update Request Handler

       http://wiki.apache.org/solr/ExtractingRequestHandler 

    -->
  <requestHandler name="/update/extract" 
                  startup="lazy"
                  class="solr.extraction.ExtractingRequestHandler" >
    <lst name="defaults">
      <!-- All the main content goes into "text"... if you need to return
           the extracted text or do highlighting, use a stored field. -->
      <str name="fmap.content">text</str>
      <str name="lowernames">true</str>
      <str name="uprefix">ignored_</str>

      <!-- capture link hrefs but ignore div attributes -->
      <str name="captureAttr">true</str>
      <str name="fmap.a">links</str>
      <str name="fmap.div">ignored_</str>
    </lst>
  </requestHandler>

  <!-- Field Analysis Request Handler

       RequestHandler that provides much the same functionality as
       analysis.jsp. Provides the ability to specify multiple field
       types and field names in the same request and outputs
       index-time and query-time analysis for each of them.

       Request parameters are:
       analysis.fieldname - field name whose analyzers are to be used

       analysis.fieldtype - field type whose analyzers are to be used
       analysis.fieldvalue - text for index-time analysis
       q (or analysis.q) - text for query time analysis
       analysis.showmatch (true|false) - When set to true and when
           query analysis is performed, the produced tokens of the
           field value analysis will be marked as "matched" for every
           token that is produces by the query analysis
   -->
  <requestHandler name="/analysis/field" 
                  startup="lazy"
                  class="solr.FieldAnalysisRequestHandler" />


  <!-- Document Analysis Handler

       http://wiki.apache.org/solr/AnalysisRequestHandler

       An analysis handler that provides a breakdown of the analysis
       process of provided docuemnts. This handler expects a (single)
       content stream with the following format:

       <docs>
         <doc>
           <field name="id">1</field>
           <field name="name">The Name</field>
           <field name="text">The Text Value</field>
         </doc>
         <doc>...</doc>
         <doc>...</doc>
         ...
       </docs>

    Note: Each document must contain a field which serves as the
    unique key. This key is used in the returned response to assoicate
    ananalysis breakdown to the analyzed document.

    Like the FieldAnalysisRequestHandler, this handler also supports
    query analysis by sending either an "analysis.query" or "q"
    request paraemter that holds the query text to be analyized. It
    also supports the "analysis.showmatch" parameter which when set to
    true, all field tokens that match the query tokens will be marked
    as a "match". 
  -->
  <requestHandler name="/analysis/document" 
                  class="solr.DocumentAnalysisRequestHandler" 
                  startup="lazy" />

  <!-- Admin Handlers

       Admin Handlers - This will register all the standard admin
       RequestHandlers.  
    -->
  <requestHandler name="/admin/" 
                  class="solr.admin.AdminHandlers" />
  <!-- This single handler is equivilent to the following... -->
  <!--
     <requestHandler name="/admin/luke"       class="solr.admin.LukeRequestHandler" />
     <requestHandler name="/admin/system"     class="solr.admin.SystemInfoHandler" />
     <requestHandler name="/admin/plugins"    class="solr.admin.PluginInfoHandler" />
     <requestHandler name="/admin/threads"    class="solr.admin.ThreadDumpHandler" />
     <requestHandler name="/admin/properties" class="solr.admin.PropertiesRequestHandler" />
     <requestHandler name="/admin/file"       class="solr.admin.ShowFileRequestHandler" >
    -->
  <!-- If you wish to hide files under ${solr.home}/conf, explicitly
       register the ShowFileRequestHandler using: 
    -->
  <!--
     <requestHandler name="/admin/file" 
                     class="solr.admin.ShowFileRequestHandler" >
       <lst name="invariants">
         <str name="hidden">synonyms.txt</str> 
         <str name="hidden">anotherfile.txt</str> 
       </lst>
     </requestHandler>
    -->

  <!-- ping/healthcheck -->
  <requestHandler name="/admin/ping" class="solr.PingRequestHandler">
    <lst name="defaults">
      <str name="qt">search</str>
      <str name="q">solrpingquery</str>
      <str name="echoParams">all</str>
    </lst>
  </requestHandler>

  <!-- Echo the request contents back to the client -->
  <requestHandler name="/debug/dump" class="solr.DumpRequestHandler" >
    <lst name="defaults">
     <str name="echoParams">explicit</str> 
     <str name="echoHandler">true</str>
    </lst>
  </requestHandler>
  
  <!-- Solr Replication

       The SolrReplicationHandler supports replicating indexes from a
       "master" used for indexing and "salves" used for queries.

       http://wiki.apache.org/solr/SolrReplication 

       In the example below, remove the <lst name="master"> section if
       this is just a slave and remove  the <lst name="slave"> section
       if this is just a master.
    -->
  <!--
     <requestHandler name="/replication" class="solr.ReplicationHandler" >
       <lst name="master">
         <str name="replicateAfter">commit</str>
         <str name="replicateAfter">startup</str>
         <str name="confFiles">schema.xml,stopwords.txt</str>
       </lst>
       <lst name="slave">
         <str name="masterUrl">http://localhost:8983/solr/replication</str>
         <str name="pollInterval">00:00:60</str>
       </lst>
     </requestHandler>
    -->

  <!-- Search Components

       Search components are registered to SolrCore and used by 
       instances of SearchHandler (which can access them by name)
       
       By default, the following components are avaliable:
       
       <searchComponent name="query"     class="solr.QueryComponent" />
       <searchComponent name="facet"     class="solr.FacetComponent" />
       <searchComponent name="mlt"       class="solr.MoreLikeThisComponent" />
       <searchComponent name="highlight" class="solr.HighlightComponent" />
       <searchComponent name="stats"     class="solr.StatsComponent" />
       <searchComponent name="debug"     class="solr.DebugComponent" />
   
       Default configuration in a requestHandler would look like:

       <arr name="components">
         <str>query</str>
         <str>facet</str>
         <str>mlt</str>
         <str>highlight</str>
         <str>stats</str>
         <str>debug</str>
       </arr>

       If you register a searchComponent to one of the standard names, 
       that will be used instead of the default.

       To insert components before or after the 'standard' components, use:
    
       <arr name="first-components">
         <str>myFirstComponentName</str>
       </arr>
    
       <arr name="last-components">
         <str>myLastComponentName</str>
       </arr>

       NOTE: The component registered with the name "debug" will
       always be executed after the "last-components" 
       
     -->

   <!-- Spell Check

        The spell check component can return a list of alternative spelling
        suggestions.  

        http://wiki.apache.org/solr/SpellCheckComponent
     -->
  <searchComponent name="spellcheck" class="solr.SpellCheckComponent">

    <str name="queryAnalyzerFieldType">textSpell</str>

    <!-- Multiple "Spell Checkers" can be declared and used by this
         component
      -->

    <!-- a spellchecker built from a field of hte main index, and
         written to disk
      -->
    <lst name="spellchecker">
      <str name="name">default</str>
      <str name="field">name</str>
      <str name="spellcheckIndexDir">spellchecker</str>
    </lst>

    <!-- a spellchecker that uses a different distance measure -->
    <!--
       <lst name="spellchecker">
         <str name="name">jarowinkler</str>
         <str name="field">spell</str>
         <str name="distanceMeasure">
           org.apache.lucene.search.spell.JaroWinklerDistance
         </str>
         <str name="spellcheckIndexDir">spellcheckerJaro</str>
       </lst>
     -->

    <!-- a spellchecker that use an alternate comparator 

         comparatorClass be one of:
          1. score (default)
          2. freq (Frequency first, then score)
          3. A fully qualified class name
      -->
    <!--
       <lst name="spellchecker">
         <str name="name">freq</str>
         <str name="field">lowerfilt</str>
         <str name="spellcheckIndexDir">spellcheckerFreq</str>
         <str name="comparatorClass">freq</str>
         <str name="buildOnCommit">true</str>
      -->

    <!-- A spellchecker that reads the list of words from a file -->
    <!--
       <lst name="spellchecker">
         <str name="classname">solr.FileBasedSpellChecker</str>
         <str name="name">file</str>
         <str name="sourceLocation">spellings.txt</str>
         <str name="characterEncoding">UTF-8</str>
         <str name="spellcheckIndexDir">spellcheckerFile</str>
       </lst>
      -->
  </searchComponent>

  <!-- A request handler for demonstrating the spellcheck component.  

       NOTE: This is purely as an example.  The whole purpose of the
       SpellCheckComponent is to hook it into the request handler that
       handles your normal user queries so that a separate request is
       not needed to get suggestions.

       IN OTHER WORDS, THERE IS REALLY GOOD CHANCE THE SETUP BELOW IS
       NOT WHAT YOU WANT FOR YOUR PRODUCTION SYSTEM!
       
       See http://wiki.apache.org/solr/SpellCheckComponent for details
       on the request parameters.
    -->
  <requestHandler name="/spell" class="solr.SearchHandler" startup="lazy">
    <lst name="defaults">
      <str name="spellcheck.onlyMorePopular">false</str>
      <str name="spellcheck.extendedResults">false</str>
      <str name="spellcheck.count">1</str>
    </lst>
    <arr name="last-components">
      <str>spellcheck</str>
    </arr>
  </requestHandler>

  <!-- Term Vector Component

       http://wiki.apache.org/solr/TermVectorComponent
    -->
  <searchComponent name="tvComponent" class="solr.TermVectorComponent"/>

  <!-- A request handler for demonstrating the term vector component

       This is purely as an example.

       In reality you will likely want to add the component to your 
       already specified request handlers. 
    -->
  <requestHandler name="tvrh" class="solr.SearchHandler" startup="lazy">
    <lst name="defaults">
      <bool name="tv">true</bool>
    </lst>
    <arr name="last-components">
      <str>tvComponent</str>
    </arr>
  </requestHandler>

  <!-- Clustering Component

       http://wiki.apache.org/solr/ClusteringComponent

       This relies on third party jars which are notincluded in the
       release.  To use this component (and the "/clustering" handler)
       Those jars will need to be downloaded, and you'll need to set
       the solr.cluster.enabled system property when running solr...

          java -Dsolr.clustering.enabled=true -jar start.jar
    -->
  <searchComponent name="clustering" 
                   enable="${solr.clustering.enabled:false}"
                   class="solr.clustering.ClusteringComponent" >
    <!-- Declare an engine -->
    <lst name="engine">
      <!-- The name, only one can be named "default" -->
      <str name="name">default</str>
      <!-- Class name of Carrot2 clustering algorithm. 
           
           Currently available algorithms are:
           
           * org.carrot2.clustering.lingo.LingoClusteringAlgorithm
           * org.carrot2.clustering.stc.STCClusteringAlgorithm
           
           See http://project.carrot2.org/algorithms.html for the
           algorithm's characteristics.
        -->
      <str name="carrot.algorithm">org.carrot2.clustering.lingo.LingoClusteringAlgorithm</str>
      <!-- Overriding values for Carrot2 default algorithm attributes.

           For a description of all available attributes, see:
           http://download.carrot2.org/stable/manual/#chapter.components.
           Use attribute key as name attribute of str elements
           below. These can be further overridden for individual
           requests by specifying attribute key as request parameter
           name and attribute value as parameter value.
        -->
      <str name="LingoClusteringAlgorithm.desiredClusterCountBase">20</str>
      
      <!-- The language to assume for the documents.
           
           For a list of allowed values, see:
           http://download.carrot2.org/stable/manual/#section.attribute.lingo.MultilingualClustering.defaultLanguage
       -->
      <str name="MultilingualClustering.defaultLanguage">ENGLISH</str>
    </lst>
    <lst name="engine">
      <str name="name">stc</str>
      <str name="carrot.algorithm">org.carrot2.clustering.stc.STCClusteringAlgorithm</str>
    </lst>
  </searchComponent>

  <!-- A request handler for demonstrating the clustering component

       This is purely as an example.

       In reality you will likely want to add the component to your 
       already specified request handlers. 
    -->
  <requestHandler name="/clustering"
                  startup="lazy"
                  enable="${solr.clustering.enabled:false}"
                  class="solr.SearchHandler">
    <lst name="defaults">
      <bool name="clustering">true</bool>
      <str name="clustering.engine">default</str>
      <bool name="clustering.results">true</bool>
      <!-- The title field -->
      <str name="carrot.title">name</str>
      <str name="carrot.url">id</str>
      <!-- The field to cluster on -->
       <str name="carrot.snippet">features</str>
       <!-- produce summaries -->
       <bool name="carrot.produceSummary">true</bool>
       <!-- the maximum number of labels per cluster -->
       <!--<int name="carrot.numDescriptions">5</int>-->
       <!-- produce sub clusters -->
       <bool name="carrot.outputSubClusters">false</bool>
       
       <str name="defType">edismax</str>
       <str name="qf">
          text^0.5 features^1.0 name^1.2 sku^1.5 id^10.0 manu^1.1 cat^1.4
       </str>
       <str name="q.alt">*:*</str>
       <str name="rows">10</str>
       <str name="fl">*,score</str>
    </lst>     
    <arr name="last-components">
      <str>clustering</str>
    </arr>
  </requestHandler>
  
  <!-- Terms Component

       http://wiki.apache.org/solr/TermsComponent

       A component to return terms and document frequency of those
       terms
    -->
  <searchComponent name="terms" class="solr.TermsComponent"/>

  <!-- A request handler for demonstrating the terms component -->
  <requestHandler name="/terms" class="solr.SearchHandler" startup="lazy">
     <lst name="defaults">
      <bool name="terms">true</bool>
    </lst>     
    <arr name="components">
      <str>terms</str>
    </arr>
  </requestHandler>


  <!-- Query Elevation Component

       http://wiki.apache.org/solr/QueryElevationComponent

       a search component that enables you to configure the top
       results for a given query regardless of the normal lucene
       scoring.
    -->
  <searchComponent name="elevator" class="solr.QueryElevationComponent" >
    <!-- pick a fieldType to analyze queries -->
    <str name="queryFieldType">string</str>
    <str name="config-file">elevate.xml</str>
  </searchComponent>

  <!-- A request handler for demonstrating the elevator component -->
  <requestHandler name="/elevate" class="solr.SearchHandler" startup="lazy">
    <lst name="defaults">
      <str name="echoParams">explicit</str>
    </lst>
    <arr name="last-components">
      <str>elevator</str>
    </arr>
  </requestHandler>

  <!-- Highlighting Component

       http://wiki.apache.org/solr/HighlightingParameters
    -->
  <searchComponent class="solr.HighlightComponent" name="highlight">
    <highlighting>
      <!-- Configure the standard fragmenter -->
      <!-- This could most likely be commented out in the "default" case -->
      <fragmenter name="gap" 
                  default="true"
                  class="solr.highlight.GapFragmenter">
        <lst name="defaults">
          <int name="hl.fragsize">100</int>
        </lst>
      </fragmenter>

      <!-- A regular-expression-based fragmenter 
           (for sentence extraction) 
        -->
      <fragmenter name="regex" 
                  class="solr.highlight.RegexFragmenter">
        <lst name="defaults">
          <!-- slightly smaller fragsizes work better because of slop -->
          <int name="hl.fragsize">70</int>
          <!-- allow 50% slop on fragment sizes -->
          <float name="hl.regex.slop">0.5</float>
          <!-- a basic sentence pattern -->
          <str name="hl.regex.pattern">[-\w ,/\n\&quot;&apos;]{20,200}</str>
        </lst>
      </fragmenter>

      <!-- Configure the standard formatter -->
      <formatter name="html" 
                 default="true"
                 class="solr.highlight.HtmlFormatter">
        <lst name="defaults">
          <str name="hl.simple.pre"><![CDATA[<em>]]></str>
          <str name="hl.simple.post"><![CDATA[</em>]]></str>
        </lst>
      </formatter>

      <!-- Configure the standard encoder -->
      <encoder name="html" 
               default="true"
               class="solr.highlight.HtmlEncoder" />

      <!-- Configure the standard fragListBuilder -->
      <fragListBuilder name="simple" 
                       default="true"
                       class="solr.highlight.SimpleFragListBuilder"/>

      <!-- Configure the single fragListBuilder -->
      <fragListBuilder name="single" 
                       class="solr.highlight.SingleFragListBuilder"/>

      <!-- default tag FragmentsBuilder -->
      <fragmentsBuilder name="default" 
                        default="true"
                        class="solr.highlight.ScoreOrderFragmentsBuilder">
        <!-- 
        <lst name="defaults">
          <str name="hl.multiValuedSeparatorChar">/</str>
        </lst>
        -->
      </fragmentsBuilder>

      <!-- multi-colored tag FragmentsBuilder -->
      <fragmentsBuilder name="colored" 
                        class="solr.highlight.ScoreOrderFragmentsBuilder">
        <lst name="defaults">
          <str name="hl.tag.pre"><![CDATA[
               <b style="background:yellow">,<b style="background:lawgreen">,
               <b style="background:aquamarine">,<b style="background:magenta">,
               <b style="background:palegreen">,<b style="background:coral">,
               <b style="background:wheat">,<b style="background:khaki">,
               <b style="background:lime">,<b style="background:deepskyblue">]]></str>
          <str name="hl.tag.post"><![CDATA[</b>]]></str>
        </lst>
      </fragmentsBuilder>
    </highlighting>
  </searchComponent>

  <!-- Update Processors

       Chains of Update Processor Factories for dealing with Update
       Requests can be declared, and then used by name in Update
       Request Processors

       http://wiki.apache.org/solr/UpdateRequestProcessor

    --> 
  <!-- Deduplication

       An example dedup update processor that creates the "id" field
       on the fly based on the hash code of some other fields.  This
       example has overwriteDupes set to false since we are using the
       id field as the signatureField and Solr will maintain
       uniqueness based on that anyway.  
       
    -->
  <!--
     <updateRequestProcessorChain name="dedupe">
       <processor class="solr.processor.SignatureUpdateProcessorFactory">
         <bool name="enabled">true</bool>
         <str name="signatureField">id</str>
         <bool name="overwriteDupes">false</bool>
         <str name="fields">name,features,cat</str>
         <str name="signatureClass">solr.processor.Lookup3Signature</str>
       </processor>
       <processor class="solr.LogUpdateProcessorFactory" />
       <processor class="solr.RunUpdateProcessorFactory" />
     </updateRequestProcessorChain>
    -->

  <!-- Response Writers

       http://wiki.apache.org/solr/QueryResponseWriter

       Request responses will be written using the writer specified by
       the 'wt' request parameter matching the name of a registered
       writer.

       The "default" writer is the default and will be used if 'wt' is
       not specified in the request.
    -->
  <!-- The following response writers are implicitly configured unless
       overridden...
    -->
  <!--
     <queryResponseWriter name="xml" 
                          default="true"
                          class="solr.XMLResponseWriter" />
     <queryResponseWriter name="json" class="solr.JSONResponseWriter"/>
     <queryResponseWriter name="python" class="solr.PythonResponseWriter"/>
     <queryResponseWriter name="ruby" class="solr.RubyResponseWriter"/>
     <queryResponseWriter name="php" class="solr.PHPResponseWriter"/>
     <queryResponseWriter name="phps" class="solr.PHPSerializedResponseWriter"/>
     <queryResponseWriter name="velocity" class="solr.VelocityResponseWriter"/>
     <queryResponseWriter name="csv" class="solr.CSVResponseWriter"/>
    -->
  <!--
     Custom response writers can be declared as needed...
    -->
  <!--
     <queryResponseWriter name="custom" class="com.example.MyResponseWriter"/>
    -->

  <!-- XSLT response writer transforms the XML output by any xslt file found
       in Solr's conf/xslt directory.  Changes to xslt files are checked for
       every xsltCacheLifetimeSeconds.  
    -->
  <queryResponseWriter name="xslt" class="solr.XSLTResponseWriter">
    <int name="xsltCacheLifetimeSeconds">5</int>
  </queryResponseWriter>

  <!-- Query Parsers

       http://wiki.apache.org/solr/SolrQuerySyntax

       Multiple QParserPlugins can be registered by name, and then
       used in either the "defType" param for the QueryComponent (used
       by SearchHandler) or in LocalParams
    -->
  <!-- example of registering a query parser -->
  <!--
     <queryParser name="myparser" class="com.mycompany.MyQParserPlugin"/>
    -->

  <!-- Function Parsers

       http://wiki.apache.org/solr/FunctionQuery

       Multiple ValueSourceParsers can be registered by name, and then
       used as function names when using the "func" QParser.
    -->
  <!-- example of registering a custom function parser  -->
  <!--
     <valueSourceParser name="myfunc" 
                        class="com.mycompany.MyValueSourceParser" />
    -->

  <!-- Legacy config for the admin interface -->
  <admin>
    <defaultQuery>*:*</defaultQuery>

    <!-- configure a healthcheck file for servers behind a
         loadbalancer 
      -->
    <!--
       <healthcheck type="file">server-enabled</healthcheck>
      -->
  </admin>

</config>
