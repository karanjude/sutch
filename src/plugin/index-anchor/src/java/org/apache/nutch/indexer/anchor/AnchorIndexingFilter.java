/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.nutch.indexer.anchor;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map.Entry;

import org.apache.avro.util.Utf8;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.nutch.indexer.IndexingException;
import org.apache.nutch.indexer.IndexingFilter;
import org.apache.nutch.indexer.NutchDocument;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.TableUtil;

/**
 * Indexing filter that indexes all inbound anchor text for a document.
 */
public class AnchorIndexingFilter implements IndexingFilter {

  public static final Logger LOG = LoggerFactory.getLogger(AnchorIndexingFilter.class);
  private Configuration conf;

  private static final Collection<WebPage.Field> FIELDS = new HashSet<WebPage.Field>();

  static {
    FIELDS.add(WebPage.Field.INLINKS);
  }

  public void setConf(Configuration conf) {
    this.conf = conf;
  }

  public Configuration getConf() {
    return this.conf;
  }

  public void addIndexBackendOptions(Configuration conf) {
  }

  @Override
  public NutchDocument filter(NutchDocument doc, String url, WebPage page)
      throws IndexingException {

    for (Entry<Utf8, Utf8> e : page.getInlinks().entrySet()) {
      doc.add("anchor", TableUtil.toString(e.getValue()));
    }

    return doc;
  }

  @Override
  public Collection<WebPage.Field> getFields() {
    return FIELDS;
  }

}
