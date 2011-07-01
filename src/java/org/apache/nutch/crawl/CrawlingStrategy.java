package org.apache.nutch.crawl;

import java.io.IOException;

import org.apache.commons.net.ftp.Configurable;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.OutputFormat;
import org.apache.nutch.plugin.Pluggable;

public interface CrawlingStrategy extends Configurable, Pluggable {

	final static String X_POINT_ID = CrawlingStrategy.class.getName();

	void Crawl();

	void runInjectorJob();

	String getName();

	void setUpInputFormat(Job currentJob, Path input) throws IOException;

	Class<? extends Mapper> getMapperClass();

	Class<?> getOutputKeyClass();

	Class<?> getOutputValueClass();

	Class<? extends OutputFormat> getOutputFormatClass();
}
