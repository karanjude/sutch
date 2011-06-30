/*******************************************************************************
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
 ******************************************************************************/
package org.apache.nutch.crawl;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.util.StringUtils;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.nutch.metadata.Nutch;
import org.apache.nutch.storage.StorageUtils;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.nutch.util.NutchJob;
import org.apache.nutch.util.NutchTool;
import org.apache.nutch.util.ToolUtil;

public class GeneratorJob extends NutchTool implements Tool {
  public static final String GENERATE_UPDATE_CRAWLDB = "generate.update.crawldb";
  public static final String GENERATOR_MIN_SCORE = "generate.min.score";
  public static final String GENERATOR_FILTER = "generate.filter";
  public static final String GENERATOR_NORMALISE = "generate.normalise";
  public static final String GENERATOR_MAX_COUNT = "generate.max.count";
  public static final String GENERATOR_COUNT_MODE = "generate.count.mode";
  public static final String GENERATOR_COUNT_VALUE_DOMAIN = "domain";
  public static final String GENERATOR_COUNT_VALUE_HOST = "host";
  public static final String GENERATOR_COUNT_VALUE_IP = "ip";
  public static final String GENERATOR_TOP_N = "generate.topN";
  public static final String GENERATOR_CUR_TIME = "generate.curTime";
  public static final String GENERATOR_DELAY = "crawl.gen.delay";
  public static final String GENERATOR_RANDOM_SEED = "generate.partition.seed";
  public static final String BATCH_ID = "generate.batch.id";

  private static final Set<WebPage.Field> FIELDS = new HashSet<WebPage.Field>();

  static {
    FIELDS.add(WebPage.Field.FETCH_TIME);
    FIELDS.add(WebPage.Field.SCORE);
    FIELDS.add(WebPage.Field.STATUS);
    FIELDS.add(WebPage.Field.MARKERS);
  }

  public static final Logger LOG = LoggerFactory.getLogger(GeneratorJob.class);

  public static class SelectorEntry
  implements WritableComparable<SelectorEntry> {

    String url;
    float score;

    public SelectorEntry() {  }

    public SelectorEntry(String url, float score) {
      this.url = url;
      this.score = score;
    }

    public void readFields(DataInput in) throws IOException {
      url = Text.readString(in);
      score = in.readFloat();
    }

    public void write(DataOutput out) throws IOException {
      Text.writeString(out, url);
      out.writeFloat(score);
    }

    public int compareTo(SelectorEntry se) {
      if (se.score > score)
        return 1;
      else if (se.score == score)
        return url.compareTo(se.url);
      return -1;
    }

    @Override
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result +  url.hashCode();
      result = prime * result + Float.floatToIntBits(score);
      return result;
    }

    @Override
    public boolean equals(Object obj) {
      SelectorEntry other = (SelectorEntry) obj;
      if (!url.equals(other.url))
        return false;
      if (Float.floatToIntBits(score) != Float.floatToIntBits(other.score))
        return false;
      return true;
    }
  }

  public static class SelectorEntryComparator extends WritableComparator {
    public SelectorEntryComparator() {
      super(SelectorEntry.class, true);
    }
  }

  static {
    WritableComparator.define(SelectorEntry.class,
                              new SelectorEntryComparator());
  }

  public GeneratorJob() {

  }

  public GeneratorJob(Configuration conf) {
    setConf(conf);
  }

  public Map<String,Object> run(Map<String,Object> args) throws Exception {
    // map to inverted subset due for fetch, sort by score
    Long topN = (Long)args.get(Nutch.ARG_TOPN);
    Long curTime = (Long)args.get(Nutch.ARG_CURTIME);
    if (curTime == null) {
      curTime = System.currentTimeMillis();
    }
    Boolean filter = (Boolean)args.get(Nutch.ARG_FILTER);
    Boolean norm = (Boolean)args.get(Nutch.ARG_NORMALIZE);
    // map to inverted subset due for fetch, sort by score
    getConf().setLong(GENERATOR_CUR_TIME, curTime);
    if (topN != null)
      getConf().setLong(GENERATOR_TOP_N, topN);
    if (filter != null)
      getConf().setBoolean(GENERATOR_FILTER, filter);
    int randomSeed = Math.abs(new Random().nextInt());
    batchId = (curTime / 1000) + "-" + randomSeed;
    getConf().setInt(GENERATOR_RANDOM_SEED, randomSeed);
    getConf().set(BATCH_ID, batchId);
    getConf().setLong(Nutch.GENERATE_TIME_KEY, System.currentTimeMillis());
    if (norm != null)
      getConf().setBoolean(GENERATOR_NORMALISE, norm);
    String mode = getConf().get(GENERATOR_COUNT_MODE, GENERATOR_COUNT_VALUE_HOST);
    if (GENERATOR_COUNT_VALUE_HOST.equalsIgnoreCase(mode)) {
      getConf().set(URLPartitioner.PARTITION_MODE_KEY, URLPartitioner.PARTITION_MODE_HOST);
    } else if (GENERATOR_COUNT_VALUE_DOMAIN.equalsIgnoreCase(mode)) {
        getConf().set(URLPartitioner.PARTITION_MODE_KEY, URLPartitioner.PARTITION_MODE_DOMAIN);
    } else {
      LOG.warn("Unknown generator.max.count mode '" + mode + "', using mode=" + GENERATOR_COUNT_VALUE_HOST);
      getConf().set(GENERATOR_COUNT_MODE, GENERATOR_COUNT_VALUE_HOST);
      getConf().set(URLPartitioner.PARTITION_MODE_KEY, URLPartitioner.PARTITION_MODE_HOST);
    }
    numJobs = 1;
    currentJobNum = 0;
    currentJob = new NutchJob(getConf(), "generate: " + batchId);
    StorageUtils.initMapperJob(currentJob, FIELDS, SelectorEntry.class,
        WebPage.class, GeneratorMapper.class, URLPartitioner.class, true);
    StorageUtils.initReducerJob(currentJob, GeneratorReducer.class);
    currentJob.waitForCompletion(true);
    ToolUtil.recordJobStatus(null, currentJob, results);
    results.put(BATCH_ID, batchId);
    return results;
  }
  
  private String batchId;
  
  /**
   * Mark URLs ready for fetching.
   * @throws ClassNotFoundException
   * @throws InterruptedException
   * */
  public String generate(long topN, long curTime, boolean filter, boolean norm)
      throws Exception {

    LOG.info("GeneratorJob: Selecting best-scoring urls due for fetch.");
    LOG.info("GeneratorJob: starting");
    LOG.info("GeneratorJob: filtering: " + filter);
    if (topN != Long.MAX_VALUE) {
      LOG.info("GeneratorJob: topN: " + topN);
    }
    run(ToolUtil.toArgMap(
        Nutch.ARG_TOPN, topN,
        Nutch.ARG_CURTIME, curTime,
        Nutch.ARG_FILTER, filter,
        Nutch.ARG_NORMALIZE, norm));
    batchId =  getConf().get(BATCH_ID);
    LOG.info("GeneratorJob: done");
    LOG.info("GeneratorJob: generated batch id: " + batchId);
    return batchId;
  }

  public int run(String[] args) throws Exception {
    long curTime = System.currentTimeMillis(), topN = Long.MAX_VALUE;
    boolean filter = true, norm = true;

    for (int i = 0; i < args.length; i++) {
      if ("-topN".equals(args[i])) {
        topN = Long.parseLong(args[++i]);
      } else if ("-noFilter".equals(args[i])) {
        filter = false;
      } else if ("-noNorm".equals(args[i])) {
        norm = false;
      } else if ("-crawlId".equals(args[i])) {
        getConf().set(Nutch.CRAWL_ID_KEY, args[++i]);
      }
    }

    try {
      return (generate(topN, curTime, filter, norm) != null) ? 0 : -1;
    } catch (Exception e) {
      LOG.error("GeneratorJob: " + StringUtils.stringifyException(e));
      return -1;
    }
  }

  public static void main(String args[]) throws Exception {
    int res = ToolRunner.run(NutchConfiguration.create(), new GeneratorJob(), args);
    System.exit(res);
  }

}
