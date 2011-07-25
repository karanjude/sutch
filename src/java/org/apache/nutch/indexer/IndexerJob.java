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
package org.apache.nutch.indexer;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;

import org.apache.avro.util.Utf8;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.RawComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.util.Tool;
import org.apache.nutch.crawl.GeneratorJob;
import org.apache.nutch.metadata.Nutch;
import org.apache.nutch.parse.ParseStatusCodes;
import org.apache.nutch.parse.ParseStatusUtils;
import org.apache.nutch.scoring.ScoringFilters;
import org.apache.nutch.storage.Mark;
import org.apache.nutch.storage.ParseStatus;
import org.apache.nutch.storage.StorageUtils;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.NutchJob;
import org.apache.nutch.util.NutchTool;
import org.apache.nutch.util.TableUtil;
import org.apache.gora.mapreduce.GoraMapper;
import org.apache.gora.mapreduce.StringComparator;

public abstract class IndexerJob extends NutchTool implements Tool {

	public static final Logger LOG = LoggerFactory.getLogger(IndexerJob.class);

	private static final Collection<WebPage.Field> FIELDS = new HashSet<WebPage.Field>();

	private static final Utf8 REINDEX = new Utf8("-reindex");

	static {
		FIELDS.add(WebPage.Field.SIGNATURE);
		FIELDS.add(WebPage.Field.PARSE_STATUS);
		FIELDS.add(WebPage.Field.SCORE);
		FIELDS.add(WebPage.Field.MARKERS);
	}

	public static class IndexerMapper extends
			GoraMapper<String, WebPage, String, WebPage> {
		protected Utf8 batchId;
		static int ctr = 0;

		@Override
		public void setup(Context context) throws IOException {
			Configuration conf = context.getConfiguration();
			batchId = new Utf8(conf.get(GeneratorJob.BATCH_ID,
					Nutch.ALL_BATCH_ID_STR));
		}

		@Override
		public void map(String key, WebPage page, Context context)
				throws IOException, InterruptedException {
			ParseStatus pstatus = page.getParseStatus();
			Utf8 mark = Mark.UPDATEDB_MARK.checkMark(page);

			boolean ismarked = null != mark;

			boolean shouldSkip = pstatus == null
					|| !ParseStatusUtils.isSuccess(pstatus)
					|| pstatus.getMinorCode() == ParseStatusCodes.SUCCESS_REDIRECT;

			if (!ismarked && shouldSkip) {
				return; // filter urls not parsed
			}

			if (!batchId.equals(REINDEX)) {
				if (!NutchJob.shouldProcess(mark, batchId)) {
					if (LOG.isDebugEnabled()) {
						LOG.debug("Skipping " + TableUtil.unreverseUrl(key)
								+ "; different batch id");
					}
					return;
				}
			}

			System.err.println(ctr + " " + key);
			ctr++;
			context.write(key, page);
		}
	}

	private static Collection<WebPage.Field> getFields(Job job) {
		Configuration conf = job.getConfiguration();
		Collection<WebPage.Field> columns = new HashSet<WebPage.Field>(FIELDS);
		IndexingFilters filters = new IndexingFilters(conf);
		columns.addAll(filters.getFields());
		ScoringFilters scoringFilters = new ScoringFilters(conf);
		columns.addAll(scoringFilters.getFields());
		columns.add(WebPage.Field.CONTENT);
		System.err.println("added content field");
		return columns;
	}

	protected Job createIndexJob(Configuration conf, String jobName,
			String batchId) throws IOException, ClassNotFoundException {
		conf.set(GeneratorJob.BATCH_ID, batchId);
		Job job = new NutchJob(conf, jobName);
		// TODO: Figure out why this needs to be here
		job.getConfiguration().setClass("mapred.output.key.comparator.class",
				StringComparator.class, RawComparator.class);

		Collection<WebPage.Field> fields = getFields(job);
		StorageUtils.initMapperJob(job, fields, String.class, WebPage.class,
				IndexerMapper.class);
		job.setReducerClass(IndexerReducer.class);
		job.setOutputFormatClass(IndexerOutputFormat.class);
		return job;
	}
}
