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
 This is the Solr schema file. This file should be named "schema.xml" and
 should be in the conf directory under the solr home
 (i.e. ./solr/conf/schema.xml by default) 
 or located where the classloader for the Solr webapp can find it.

 This example schema is the recommended starting point for users.
 It should be kept correct and concise, usable out-of-the-box.

 For more information, on how to customize this file, please see
 http://wiki.apache.org/solr/SchemaXml

 PERFORMANCE NOTE: this schema includes many optional features and should not
 be used for benchmarking.  To improve performance one could
  - set stored="false" for all fields possible (esp large fields) when you
    only need to search on the field but don't need to return the original
    value.
  - set indexed="false" if you don't need to search on the field, but only
    return the field as a result of searching on other indexed fields.
  - remove all unneeded copyField statements
  - for best index size and searching performance, set "index" to false
    for all general text fields, use copyField to copy them to the
    catchall "text" field, and use that for searching.
  - For maximum indexing performance, use the StreamingUpdateSolrServer
    java client.
  - Remember to run the JVM in server mode, and use a higher logging level
    that avoids logging every request
-->

<schema name="example" version="1.3">
  <!-- attribute "name" is the name of this schema and is only used for display purposes.
       Applications should change this to reflect the nature of the search collection.
       version="1.2" is Solr's version number for the schema syntax and semantics.  It should
       not normally be changed by applications.
       1.0: multiValued attribute did not exist, all fields are multiValued by nature
       1.1: multiValued attribute introduced, false by default 
       1.2: omitTermFreqAndPositions attribute introduced, true by default except for text fields.
       1.3: removed optional field compress feature
     -->

  <types>
    <!-- field type definitions. The "name" attribute is
       just a label to be used by field definitions.  The "class"
       attribute and any other attributes determine the real
       behavior of the fieldType.
         Class names starting with "solr" refer to java classes in the
       org.apache.solr.analysis package.
    -->

    <!-- The StrField type is not analyzed, but indexed/stored verbatim. -->
    <fieldType name="string" class="solr.StrField" sortMissingLast="true" omitNorms="true"/>

    <!-- boolean type: "true" or "false" -->
    <fieldType name="boolean" class="solr.BoolField" sortMissingLast="true" omitNorms="true"/>
    <!--Binary data type. The data should be sent/retrieved in as Base64 encoded Strings -->
    <fieldtype name="binary" class="solr.BinaryField"/>

    <!-- The optional sortMissingLast and sortMissingFirst attributes are
         currently supported on types that are sorted internally as strings.
	       This includes "string","boolean","sint","slong","sfloat","sdouble","pdate"
       - If sortMissingLast="true", then a sort on this field will cause documents
         without the field to come after documents with the field,
         regardless of the requested sort order (asc or desc).
       - If sortMissingFirst="true", then a sort on this field will cause documents
         without the field to come before documents with the field,
         regardless of the requested sort order.
       - If sortMissingLast="false" and sortMissingFirst="false" (the default),
         then default lucene sorting will be used which places docs without the
         field first in an ascending sort and last in a descending sort.
    -->    

    <!--
      Default numeric field types. For faster range queries, consider the tint/tfloat/tlong/tdouble types.
    -->
    <fieldType name="int" class="solr.TrieIntField" precisionStep="0" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="float" class="solr.TrieFloatField" precisionStep="0" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="long" class="solr.TrieLongField" precisionStep="0" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="double" class="solr.TrieDoubleField" precisionStep="0" omitNorms="true" positionIncrementGap="0"/>

    <!--
     Numeric field types that index each value at various levels of precision
     to accelerate range queries when the number of values between the range
     endpoints is large. See the javadoc for NumericRangeQuery for internal
     implementation details.

     Smaller precisionStep values (specified in bits) will lead to more tokens
     indexed per value, slightly larger index size, and faster range queries.
     A precisionStep of 0 disables indexing at different precision levels.
    -->
    <fieldType name="tint" class="solr.TrieIntField" precisionStep="8" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="tfloat" class="solr.TrieFloatField" precisionStep="8" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="tlong" class="solr.TrieLongField" precisionStep="8" omitNorms="true" positionIncrementGap="0"/>
    <fieldType name="tdouble" class="solr.TrieDoubleField" precisionStep="8" omitNorms="true" positionIncrementGap="0"/>

    <!-- The format for this date field is of the form 1995-12-31T23:59:59Z, and
         is a more restricted form of the canonical representation of dateTime
         http://www.w3.org/TR/xmlschema-2/#dateTime    
         The trailing "Z" designates UTC time and is mandatory.
         Optional fractional seconds are allowed: 1995-12-31T23:59:59.999Z
         All other components are mandatory.

         Expressions can also be used to denote calculations that should be
         performed relative to "NOW" to determine the value, ie...

               NOW/HOUR
                  ... Round to the start of the current hour
               NOW-1DAY
                  ... Exactly 1 day prior to now
               NOW/DAY+6MONTHS+3DAYS
                  ... 6 months and 3 days in the future from the start of
                      the current day
                      
         Consult the DateField javadocs for more information.

         Note: For faster range queries, consider the tdate type
      -->
    <fieldType name="date" class="solr.TrieDateField" omitNorms="true" precisionStep="0" positionIncrementGap="0"/>

    <!-- A Trie based date field for faster date range queries and date faceting. -->
    <fieldType name="tdate" class="solr.TrieDateField" omitNorms="true" precisionStep="6" positionIncrementGap="0"/>


    <!--
      Note:
      These should only be used for compatibility with existing indexes (created with older Solr versions)
      or if "sortMissingFirst" or "sortMissingLast" functionality is needed. Use Trie based fields instead.

      Plain numeric field types that store and index the text
      value verbatim (and hence don't support range queries, since the
      lexicographic ordering isn't equal to the numeric ordering)
    -->
    <fieldType name="pint" class="solr.IntField" omitNorms="true"/>
    <fieldType name="plong" class="solr.LongField" omitNorms="true"/>
    <fieldType name="pfloat" class="solr.FloatField" omitNorms="true"/>
    <fieldType name="pdouble" class="solr.DoubleField" omitNorms="true"/>
    <fieldType name="pdate" class="solr.DateField" sortMissingLast="true" omitNorms="true"/>


    <!--
      Note:
      These should only be used for compatibility with existing indexes (created with older Solr versions)
      or if "sortMissingFirst" or "sortMissingLast" functionality is needed. Use Trie based fields instead.

      Numeric field types that manipulate the value into
      a string value that isn't human-readable in its internal form,
      but with a lexicographic ordering the same as the numeric ordering,
      so that range queries work correctly.
    -->
    <fieldType name="sint" class="solr.SortableIntField" sortMissingLast="true" omitNorms="true"/>
    <fieldType name="slong" class="solr.SortableLongField" sortMissingLast="true" omitNorms="true"/>
    <fieldType name="sfloat" class="solr.SortableFloatField" sortMissingLast="true" omitNorms="true"/>
    <fieldType name="sdouble" class="solr.SortableDoubleField" sortMissingLast="true" omitNorms="true"/>


    <!-- The "RandomSortField" is not used to store or search any
         data.  You can declare fields of this type it in your schema
         to generate pseudo-random orderings of your docs for sorting 
         purposes.  The ordering is generated based on the field name 
         and the version of the index, As long as the index version
         remains unchanged, and the same field name is reused,
         the ordering of the docs will be consistent.  
         If you want different psuedo-random orderings of documents,
         for the same version of the index, use a dynamicField and
         change the name
     -->
    <fieldType name="random" class="solr.RandomSortField" indexed="true" />

    <!-- solr.TextField allows the specification of custom text analyzers
         specified as a tokenizer and a list of token filters. Different
         analyzers may be specified for indexing and querying.

         The optional positionIncrementGap puts space between multiple fields of
         this type on the same document, with the purpose of preventing false phrase
         matching across fields.

         For more info on customizing your analyzer chain, please see
         http://wiki.apache.org/solr/AnalyzersTokenizersTokenFilters
     -->

    <!-- One can also specify an existing Analyzer class that has a
         default constructor via the class attribute on the analyzer element
    <fieldType name="text_greek" class="solr.TextField">
      <analyzer class="org.apache.lucene.analysis.el.GreekAnalyzer"/>
    </fieldType>
    -->

    <!-- A text field that only splits on whitespace for exact matching of words -->
    <fieldType name="text_ws" class="solr.TextField" positionIncrementGap="100">
      <analyzer>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
      </analyzer>
    </fieldType>

    <!-- A text field that uses WordDelimiterFilter to enable splitting and matching of
        words on case-change, alpha numeric boundaries, and non-alphanumeric chars,
        so that a query of "wifi" or "wi fi" could match a document containing "Wi-Fi".
        Synonyms and stopwords are customized by external files, and stemming is enabled.
        The attribute autoGeneratePhraseQueries="true" (the default) causes words that get split to
        form phrase queries. For example, WordDelimiterFilter splitting text:pdp-11 will cause the parser
        to generate text:"pdp 11" rather than (text:PDP OR text:11).
        NOTE: autoGeneratePhraseQueries="true" tends to not work well for non whitespace delimited languages.
        -->
    <fieldType name="text" class="solr.TextField" positionIncrementGap="100" autoGeneratePhraseQueries="true">
      <analyzer type="index">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <!-- in this example, we will only use synonyms at query time
        <filter class="solr.SynonymFilterFactory" synonyms="index_synonyms.txt" ignoreCase="true" expand="false"/>
        -->
        <!-- Case insensitive stop word removal.
          add enablePositionIncrements=true in both the index and query
          analyzers to leave a 'gap' for more accurate phrase queries.
        -->
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                enablePositionIncrements="true"
                />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="1" catenateNumbers="1" catenateAll="0" splitOnCaseChange="1"/>
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.KeywordMarkerFilterFactory" protected="protwords.txt"/>
        <filter class="solr.PorterStemFilterFactory"/>
      </analyzer>
      <analyzer type="query">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                enablePositionIncrements="true"
                />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="0" catenateNumbers="0" catenateAll="0" splitOnCaseChange="1"/>
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.KeywordMarkerFilterFactory" protected="protwords.txt"/>
        <filter class="solr.PorterStemFilterFactory"/>
      </analyzer>
    </fieldType>


    <!-- Less flexible matching, but less false matches.  Probably not ideal for product names,
         but may be good for SKUs.  Can insert dashes in the wrong place and still match. -->
    <fieldType name="textTight" class="solr.TextField" positionIncrementGap="100" >
      <analyzer>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="false"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt"/>
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="0" generateNumberParts="0" catenateWords="1" catenateNumbers="1" catenateAll="0"/>
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.KeywordMarkerFilterFactory" protected="protwords.txt"/>
        <filter class="solr.EnglishMinimalStemFilterFactory"/>
        <!-- this filter can remove any duplicate tokens that appear at the same position - sometimes
             possible with WordDelimiterFilter in conjuncton with stemming. -->
        <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
      </analyzer>
    </fieldType>


    <!-- A general unstemmed text field - good if one does not know the language of the field -->
    <fieldType name="textgen" class="solr.TextField" positionIncrementGap="100">
      <analyzer type="index">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt" enablePositionIncrements="true" />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="1" catenateNumbers="1" catenateAll="0" splitOnCaseChange="0"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
      <analyzer type="query">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                enablePositionIncrements="true"
                />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="0" catenateNumbers="0" catenateAll="0" splitOnCaseChange="0"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
    </fieldType>


    <!-- A general unstemmed text field that indexes tokens normally and also
         reversed (via ReversedWildcardFilterFactory), to enable more efficient 
	 leading wildcard queries. -->
    <fieldType name="text_rev" class="solr.TextField" positionIncrementGap="100">
      <analyzer type="index">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt" enablePositionIncrements="true" />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="1" catenateNumbers="1" catenateAll="0" splitOnCaseChange="0"/>
        <filter class="solr.LowerCaseFilterFactory"/>
        <filter class="solr.ReversedWildcardFilterFactory" withOriginal="true"
           maxPosAsterisk="3" maxPosQuestion="2" maxFractionAsterisk="0.33"/>
      </analyzer>
      <analyzer type="query">
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <filter class="solr.SynonymFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.StopFilterFactory"
                ignoreCase="true"
                words="stopwords.txt"
                enablePositionIncrements="true"
                />
        <filter class="solr.WordDelimiterFilterFactory" generateWordParts="1" generateNumberParts="1" catenateWords="0" catenateNumbers="0" catenateAll="0" splitOnCaseChange="0"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
    </fieldType>

    <!-- charFilter + WhitespaceTokenizer  -->
    <!--
    <fieldType name="textCharNorm" class="solr.TextField" positionIncrementGap="100" >
      <analyzer>
        <charFilter class="solr.MappingCharFilterFactory" mapping="mapping-ISOLatin1Accent.txt"/>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
      </analyzer>
    </fieldType>
    -->

    <!-- This is an example of using the KeywordTokenizer along
         With various TokenFilterFactories to produce a sortable field
         that does not include some properties of the source text
      -->
    <fieldType name="alphaOnlySort" class="solr.TextField" sortMissingLast="true" omitNorms="true">
      <analyzer>
        <!-- KeywordTokenizer does no actual tokenizing, so the entire
             input string is preserved as a single token
          -->
        <tokenizer class="solr.KeywordTokenizerFactory"/>
        <!-- The LowerCase TokenFilter does what you expect, which can be
             when you want your sorting to be case insensitive
          -->
        <filter class="solr.LowerCaseFilterFactory" />
        <!-- The TrimFilter removes any leading or trailing whitespace -->
        <filter class="solr.TrimFilterFactory" />
        <!-- The PatternReplaceFilter gives you the flexibility to use
             Java Regular expression to replace any sequence of characters
             matching a pattern with an arbitrary replacement string, 
             which may include back references to portions of the original
             string matched by the pattern.
             
             See the Java Regular Expression documentation for more
             information on pattern and replacement string syntax.
             
             http://java.sun.com/j2se/1.5.0/docs/api/java/util/regex/package-summary.html
          -->
        <filter class="solr.PatternReplaceFilterFactory"
                pattern="([^a-z])" replacement="" replace="all"
        />
      </analyzer>
    </fieldType>
    
    <fieldtype name="phonetic" stored="false" indexed="true" class="solr.TextField" >
      <analyzer>
        <tokenizer class="solr.StandardTokenizerFactory"/>
        <filter class="solr.DoubleMetaphoneFilterFactory" inject="false"/>
      </analyzer>
    </fieldtype>

    <fieldtype name="payloads" stored="false" indexed="true" class="solr.TextField" >
      <analyzer>
        <tokenizer class="solr.WhitespaceTokenizerFactory"/>
        <!--
        The DelimitedPayloadTokenFilter can put payloads on tokens... for example,
        a token of "foo|1.4"  would be indexed as "foo" with a payload of 1.4f
        Attributes of the DelimitedPayloadTokenFilterFactory : 
         "delimiter" - a one character delimiter. Default is | (pipe)
	 "encoder" - how to encode the following value into a playload
	    float -> org.apache.lucene.analysis.payloads.FloatEncoder,
	    integer -> o.a.l.a.p.IntegerEncoder
	    identity -> o.a.l.a.p.IdentityEncoder
            Fully Qualified class name implementing PayloadEncoder, Encoder must have a no arg constructor.
         -->
        <filter class="solr.DelimitedPayloadTokenFilterFactory" encoder="float"/>
      </analyzer>
    </fieldtype>

    <!-- lowercases the entire field value, keeping it as a single token.  -->
    <fieldType name="lowercase" class="solr.TextField" positionIncrementGap="100">
      <analyzer>
        <tokenizer class="solr.KeywordTokenizerFactory"/>
        <filter class="solr.LowerCaseFilterFactory" />
      </analyzer>
    </fieldType>

    <fieldType name="text_path" class="solr.TextField" positionIncrementGap="100">
      <analyzer>
        <tokenizer class="solr.PathHierarchyTokenizerFactory"/>
      </analyzer>
    </fieldType>

    <!-- since fields of this type are by default not stored or indexed,
         any data added to them will be ignored outright.  --> 
    <fieldtype name="ignored" stored="false" indexed="false" multiValued="true" class="solr.StrField" />

    <!-- This point type indexes the coordinates as separate fields (subFields)
      If subFieldType is defined, it references a type, and a dynamic field
      definition is created matching *___<typename>.  Alternately, if 
      subFieldSuffix is defined, that is used to create the subFields.
      Example: if subFieldType="double", then the coordinates would be
        indexed in fields myloc_0___double,myloc_1___double.
      Example: if subFieldSuffix="_d" then the coordinates would be indexed
        in fields myloc_0_d,myloc_1_d
      The subFields are an implementation detail of the fieldType, and end
      users normally should not need to know about them.
     -->
    <fieldType name="point" class="solr.PointType" dimension="2" subFieldSuffix="_d"/>

    <!-- A specialized field for geospatial search. If indexed, this fieldType must not be multivalued. -->
    <fieldType name="location" class="solr.LatLonType" subFieldSuffix="_coordinate"/>

   <!--
    A Geohash is a compact representation of a latitude longitude pair in a single field.
    See http://wiki.apache.org/solr/SpatialSearch
   -->
    <fieldtype name="geohash" class="solr.GeoHashField"/>
 </types>


 <fields>
   <!-- Valid attributes for fields:
     name: mandatory - the name for the field
     type: mandatory - the name of a previously defined type from the 
       <types> section
     indexed: true if this field should be indexed (searchable or sortable)
     stored: true if this field should be retrievable
     multiValued: true if this field may contain multiple values per document
     omitNorms: (expert) set to true to omit the norms associated with
       this field (this disables length normalization and index-time
       boosting for the field, and saves some memory).  Only full-text
       fields or fields that need an index-time boost need norms.
     termVectors: [false] set to true to store the term vector for a
       given field.
       When using MoreLikeThis, fields used for similarity should be
       stored for best performance.
     termPositions: Store position information with the term vector.  
       This will increase storage costs.
     termOffsets: Store offset information with the term vector. This 
       will increase storage costs.
     default: a value that should be used if no value is specified
       when adding a document.
   -->

   <field name="id" type="string" indexed="true" stored="true" required="true" /> 
   <field name="sku" type="textTight" indexed="true" stored="true" omitNorms="true"/>
   <field name="name" type="textgen" indexed="true" stored="true"/>
   <field name="alphaNameSort" type="alphaOnlySort" indexed="true" stored="false"/>
   <field name="manu" type="textgen" indexed="true" stored="true" omitNorms="true"/>
   <field name="cat" type="string" indexed="true" stored="true" multiValued="true"/>
   <field name="features" type="text" indexed="true" stored="true" multiValued="true"/>
   <field name="includes" type="text" indexed="true" stored="true" termVectors="true" termPositions="true" termOffsets="true" />

   <field name="weight" type="float" indexed="true" stored="true"/>
   <field name="price"  type="float" indexed="true" stored="true"/>
   <field name="popularity" type="int" indexed="true" stored="true" />
   <field name="inStock" type="boolean" indexed="true" stored="true" />

   <!--
   The following store examples are used to demonstrate the various ways one might _CHOOSE_ to
    implement spatial.  It is highly unlikely that you would ever have ALL of these fields defined.
    -->
   <field name="store" type="location" indexed="true" stored="true"/>

   <!-- Common metadata fields, named specifically to match up with
     SolrCell metadata when parsing rich documents such as Word, PDF.
     Some fields are multiValued only because Tika currently may return
     multiple values for them.
   -->
   <field name="title" type="text" indexed="true" stored="true" multiValued="true"/>
   <field name="subject" type="text" indexed="true" stored="true"/>
   <field name="description" type="text" indexed="true" stored="true"/>
   <field name="comments" type="text" indexed="true" stored="true"/>
   <field name="author" type="textgen" indexed="true" stored="true"/>
   <field name="keywords" type="textgen" indexed="true" stored="true"/>
   <field name="category" type="textgen" indexed="true" stored="true"/>
   <field name="content_type" type="string" indexed="true" stored="true" multiValued="true"/>
   <field name="last_modified" type="date" indexed="true" stored="true"/>
   <field name="links" type="string" indexed="true" stored="true" multiValued="true"/>


   <!-- catchall field, containing all other searchable text fields (implemented
        via copyField further on in this schema  -->
   <field name="text" type="text" indexed="true" stored="false" multiValued="true"/>

   <!-- catchall text field that indexes tokens both normally and in reverse for efficient
        leading wildcard queries. -->
   <field name="text_rev" type="text_rev" indexed="true" stored="false" multiValued="true"/>

   <!-- non-tokenized version of manufacturer to make it easier to sort or group
        results by manufacturer.  copied from "manu" via copyField -->
   <field name="manu_exact" type="string" indexed="true" stored="false"/>

   <field name="payloads" type="payloads" indexed="true" stored="true"/>

   <!-- Uncommenting the following will create a "timestamp" field using
        a default value of "NOW" to indicate when each document was indexed.
     -->
   <!--
   <field name="timestamp" type="date" indexed="true" stored="true" default="NOW" multiValued="false"/>
     -->
   

   <!-- Dynamic field definitions.  If a field name is not found, dynamicFields
        will be used if the name matches any of the patterns.
        RESTRICTION: the glob-like pattern in the name attribute must have
        a "*" only at the start or the end.
        EXAMPLE:  name="*_i" will match any field ending in _i (like myid_i, z_i)
        Longer patterns will be matched first.  if equal size patterns
        both match, the first appearing in the schema will be used.  -->
   <dynamicField name="*_i"  type="int"    indexed="true"  stored="true"/>
   <dynamicField name="*_s"  type="string"  indexed="true"  stored="true"/>
   <dynamicField name="*_l"  type="long"   indexed="true"  stored="true"/>
   <dynamicField name="*_t"  type="text"    indexed="true"  stored="true"/>
   <dynamicField name="*_txt" type="text"    indexed="true"  stored="true" multiValued="true"/>
   <dynamicField name="*_b"  type="boolean" indexed="true"  stored="true"/>
   <dynamicField name="*_f"  type="float"  indexed="true"  stored="true"/>
   <dynamicField name="*_d"  type="double" indexed="true"  stored="true"/>

   <!-- Type used to index the lat and lon components for the "location" FieldType -->
   <dynamicField name="*_coordinate"  type="tdouble" indexed="true"  stored="false"/>

   <dynamicField name="*_dt" type="date"    indexed="true"  stored="true"/>
   <dynamicField name="*_p"  type="location" indexed="true" stored="true"/>

   <!-- some trie-coded dynamic fields for faster range queries -->
   <dynamicField name="*_ti" type="tint"    indexed="true"  stored="true"/>
   <dynamicField name="*_tl" type="tlong"   indexed="true"  stored="true"/>
   <dynamicField name="*_tf" type="tfloat"  indexed="true"  stored="true"/>
   <dynamicField name="*_td" type="tdouble" indexed="true"  stored="true"/>
   <dynamicField name="*_tdt" type="tdate"  indexed="true"  stored="true"/>

   <dynamicField name="*_pi"  type="pint"    indexed="true"  stored="true"/>

   <dynamicField name="ignored_*" type="ignored" multiValued="true"/>
   <dynamicField name="attr_*" type="textgen" indexed="true" stored="true" multiValued="true"/>

   <dynamicField name="random_*" type="random" />

   <!-- uncomment the following to ignore any fields that don't already match an existing 
        field name or dynamic field, rather than reporting them as an error. 
        alternately, change the type="ignored" to some other type e.g. "text" if you want 
        unknown fields indexed and/or stored by default --> 
   <!--dynamicField name="*" type="ignored" multiValued="true" /-->
   
 </fields>

 <!-- Field to use to determine and enforce document uniqueness. 
      Unless this field is marked with required="false", it will be a required field
   -->
 <uniqueKey>id</uniqueKey>

 <!-- field for the QueryParser to use when an explicit fieldname is absent -->
 <defaultSearchField>text</defaultSearchField>

 <!-- SolrQueryParser configuration: defaultOperator="AND|OR" -->
 <solrQueryParser defaultOperator="OR"/>

  <!-- copyField commands copy one field to another at the time a document
        is added to the index.  It's used either to index the same field differently,
        or to add multiple fields to the same field for easier/faster searching.  -->

   <copyField source="cat" dest="text"/>
   <copyField source="name" dest="text"/>
   <copyField source="manu" dest="text"/>
   <copyField source="features" dest="text"/>
   <copyField source="includes" dest="text"/>
   <copyField source="manu" dest="manu_exact"/>
	
   <!-- Above, multiple source fields are copied to the [text] field. 
	  Another way to map multiple source fields to the same 
	  destination field is to use the dynamic field syntax. 
	  copyField also supports a maxChars to copy setting.  -->
	   
   <!-- <copyField source="*_t" dest="text" maxChars="3000"/> -->

   <!-- copy name to alphaNameSort, a field designed for sorting by name -->
   <!-- <copyField source="name" dest="alphaNameSort"/> -->
 

 <!-- Similarity is the scoring routine for each document vs. a query.
      A custom similarity may be specified here, but the default is fine
      for most applications.  -->
 <!-- <similarity class="org.apache.lucene.search.DefaultSimilarity"/> -->
 <!-- ... OR ...
      Specify a SimilarityFactory class name implementation
      allowing parameters to be used.
 -->
 <!--
 <similarity class="com.example.solr.CustomSimilarityFactory">
   <str name="paramkey">param value</str>
 </similarity>
 -->


</schema>
