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
package org.apache.nutch.parse;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;

import org.apache.avro.util.Utf8;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.nutch.crawl.GeneratorJob;
import org.apache.nutch.crawl.SignatureFactory;
import org.apache.nutch.crawl.URLWebPage;
import org.apache.nutch.metadata.Nutch;
import org.apache.nutch.storage.Mark;
import org.apache.nutch.storage.ParseStatus;
import org.apache.nutch.storage.StorageUtils;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.IdentityPageReducer;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.nutch.util.NutchJob;
import org.apache.nutch.util.NutchTool;
import org.apache.nutch.util.TableUtil;
import org.apache.nutch.util.ToolUtil;
import org.apache.gora.mapreduce.GoraMapper;

public class ParserJob extends NutchTool implements Tool {

  public static final Logger LOG = LoggerFactory.getLogger(ParserJob.class);

  private static final String RESUME_KEY = "parse.job.resume";
  private static final String FORCE_KEY = "parse.job.force";

  private static final Collection<WebPage.Field> FIELDS = new HashSet<WebPage.Field>();

  private Configuration conf;

  static {
    FIELDS.add(WebPage.Field.STATUS);
    FIELDS.add(WebPage.Field.CONTENT);
    FIELDS.add(WebPage.Field.CONTENT_TYPE);
    FIELDS.add(WebPage.Field.SIGNATURE);
    FIELDS.add(WebPage.Field.MARKERS);
    FIELDS.add(WebPage.Field.PARSE_STATUS);
    FIELDS.add(WebPage.Field.OUTLINKS);
    FIELDS.add(WebPage.Field.METADATA);
  }


  public static class ParserMapper 
      extends GoraMapper<String, WebPage, String, WebPage> {
    private ParseUtil parseUtil;

    private boolean shouldResume;

    private boolean force;

    private Utf8 batchId;
    
    @Override
    public void setup(Context context) throws IOException {
      Configuration conf = context.getConfiguration();
      parseUtil = new ParseUtil(conf);
      shouldResume = conf.getBoolean(RESUME_KEY, false);
      force = conf.getBoolean(FORCE_KEY, false);
      batchId = new Utf8(conf.get(GeneratorJob.BATCH_ID, Nutch.ALL_BATCH_ID_STR));
    }

    @Override
    public void map(String key, WebPage page, Context context)
        throws IOException, InterruptedException {
      Utf8 mark = Mark.FETCH_MARK.checkMark(page);
      if (!NutchJob.shouldProcess(mark, batchId)) {
        if (LOG.isDebugEnabled()) {
          LOG.debug("Skipping " + TableUtil.unreverseUrl(key) + "; different batch id");
        }
        return;
      }
      if (shouldResume && Mark.PARSE_MARK.checkMark(page) != null) {
        if (force) {
          if (LOG.isDebugEnabled()) {
            LOG.debug("Forced parsing " + TableUtil.unreverseUrl(key) + "; already parsed");
          }
        } else {
          if (LOG.isDebugEnabled()) {
            LOG.debug("Skipping " + TableUtil.unreverseUrl(key) + "; already parsed");
          }
          return;
        }
      }

      URLWebPage redirectedPage = parseUtil.process(key, page);
      ParseStatus pstatus = page.getParseStatus();
      if (pstatus != null) {
        context.getCounter("ParserStatus",
            ParseStatusCodes.majorCodes[pstatus.getMajorCode()]).increment(1);
      }

      if (redirectedPage != null) {
        context.write(TableUtil.reverseUrl(redirectedPage.getUrl()),
                      redirectedPage.getDatum());
      }
      context.write(key, page);
    }    
  }
  
  public ParserJob() {

  }

  public ParserJob(Configuration conf) {
    setConf(conf);
  }

  public Collection<WebPage.Field> getFields(Job job) {
    Configuration conf = job.getConfiguration();
    Collection<WebPage.Field> fields = new HashSet<WebPage.Field>(FIELDS);
    ParserFactory parserFactory = new ParserFactory(conf);
    ParseFilters parseFilters = new ParseFilters(conf);

    Collection<WebPage.Field> parsePluginFields = parserFactory.getFields();
    Collection<WebPage.Field> signaturePluginFields =
      SignatureFactory.getFields(conf);
    Collection<WebPage.Field> htmlParsePluginFields = parseFilters.getFields();

    if (parsePluginFields != null) {
      fields.addAll(parsePluginFields);
    }
    if (signaturePluginFields != null) {
      fields.addAll(signaturePluginFields);
    }
    if (htmlParsePluginFields != null) {
      fields.addAll(htmlParsePluginFields);
    }

    return fields;
  }

  @Override
  public Configuration getConf() {
    return conf;
  }

  @Override
  public void setConf(Configuration conf) {
    this.conf = conf;
  }

  @Override
  public Map<String,Object> run(Map<String,Object> args) throws Exception {
    String batchId = (String)args.get(Nutch.ARG_BATCH);
    Boolean shouldResume = (Boolean)args.get(Nutch.ARG_RESUME);
    Boolean force = (Boolean)args.get(Nutch.ARG_FORCE);
    
    if (batchId != null) {
      getConf().set(GeneratorJob.BATCH_ID, batchId);
    }
    if (shouldResume != null) {
      getConf().setBoolean(RESUME_KEY, shouldResume);
    }
    if (force != null) {
      getConf().setBoolean(FORCE_KEY, force);
    }
    currentJob = new NutchJob(getConf(), "parse");
    
    Collection<WebPage.Field> fields = getFields(currentJob);
    StorageUtils.initMapperJob(currentJob, fields, String.class, WebPage.class,
        ParserMapper.class);
    StorageUtils.initReducerJob(currentJob, IdentityPageReducer.class);
    currentJob.setNumReduceTasks(0);

    currentJob.waitForCompletion(true);
    ToolUtil.recordJobStatus(null, currentJob, results);
    return results;
  }

  public int parse(String batchId, boolean shouldResume, boolean force) throws Exception {
    LOG.info("ParserJob: starting");

    LOG.info("ParserJob: resuming:\t" + getConf().getBoolean(RESUME_KEY, false));
    LOG.info("ParserJob: forced reparse:\t" + getConf().getBoolean(FORCE_KEY, false));
    if (batchId == null || batchId.equals(Nutch.ALL_BATCH_ID_STR)) {
      LOG.info("ParserJob: parsing all");
    } else {
      LOG.info("ParserJob: batchId:\t" + batchId);
    }
    run(ToolUtil.toArgMap(
        Nutch.ARG_BATCH, batchId,
        Nutch.ARG_RESUME, shouldResume,
        Nutch.ARG_FORCE, force));
    LOG.info("ParserJob: success");
    return 0;
  }

  public int run(String[] args) throws Exception {
    boolean shouldResume = false;
    boolean force = false;
    String batchId = null;

    if (args.length < 1) {
      System.err.println("Usage: ParserJob (<batchId> | -all) [-crawlId <id>] [-resume] [-force]");
      System.err.println("\tbatchId\tsymbolic batch ID created by Generator");
      System.err.println("\t-crawlId <id>\t the id to prefix the schemas to operate on, (default: storage.crawl.id)");
      System.err.println("\t-all\tconsider pages from all crawl jobs");
      System.err.println("-resume\tresume a previous incomplete job");
      System.err.println("-force\tforce re-parsing even if a page is already parsed");
      return -1;
    }
    for (int i = 0; i < args.length; i++) {
      if ("-resume".equals(args[i])) {
        shouldResume = true;
      } else if ("-force".equals(args[i])) {
        force = true;
      } else if ("-crawlId".equals(args[i])) {
        getConf().set(Nutch.CRAWL_ID_KEY, args[++i]);
      } else if ("-all".equals(args[i])) {
        batchId = args[i];
      } else {
        if (batchId != null) {
          System.err.println("BatchId already set to '" + batchId + "'!");
          return -1;
        }
        batchId = args[i];
      }
    }
    if (batchId == null) {
      System.err.println("BatchId not set (or -all not specified)!");
      return -1;
    }
    return parse(batchId, shouldResume, force);
  }

  public static void main(String[] args) throws Exception {
    final int res = ToolRunner.run(NutchConfiguration.create(),
        new ParserJob(), args);
    System.exit(res);
  }

}
