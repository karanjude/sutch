package org.apache.nutch.crawl.strategy;

import java.io.IOException;

import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.gora.mapreduce.GoraOutputFormat;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.OutputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.nutch.crawl.CrawlingStrategy;
import org.apache.nutch.crawl.InjectorJob.UrlMapper;
import org.apache.nutch.storage.WebPage;

public class DefaultCrawler implements CrawlingStrategy {

	@Override
	public void Crawl() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void runInjectorJob() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void configure(FTPClientConfig arg0) {
		
	}

	@Override
	public String getName() {
		return "inject-p1 ";
	}

	@Override
	public void setUpInputFormat(Job currentJob, Path input) throws IOException {
	    FileInputFormat.addInputPath(currentJob, input);
	}

	@Override
	public Class<? extends Mapper> getMapperClass() {
		return UrlMapper.class;
	}

	@Override
	public Class<?> getOutputKeyClass() {
		return String.class;
	}

	@Override
	public Class<?> getOutputValueClass() {
		return WebPage.class;
	}

	@Override
	public Class<? extends OutputFormat> getOutputFormatClass() {
		return GoraOutputFormat.class;
	}

}
