/*
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
package org.apache.nutch.parse.tika;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;

import org.apache.avro.util.Utf8;
import org.apache.hadoop.conf.Configuration;
import org.apache.html.dom.HTMLDocumentImpl;
import org.apache.nutch.metadata.Nutch;
import org.apache.nutch.parse.HTMLMetaTags;
import org.apache.nutch.parse.Outlink;
import org.apache.nutch.parse.OutlinkExtractor;
import org.apache.nutch.parse.Parse;
import org.apache.nutch.parse.ParseFilters;
import org.apache.nutch.parse.ParseStatusCodes;
import org.apache.nutch.parse.ParseStatusUtils;
import org.apache.nutch.parse.ParseUtil;
import org.apache.nutch.storage.ParseStatus;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.storage.WebPage.Field;
import org.apache.nutch.util.Bytes;
import org.apache.nutch.util.MimeUtil;
import org.apache.nutch.util.NutchConfiguration;
import org.apache.nutch.util.TableUtil;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.mime.MimeType;
import org.apache.tika.parser.ParseContext;
import org.apache.tika.parser.Parser;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.DocumentFragment;

/**
 * Wrapper for Tika parsers. Mimics the HTMLParser but using the XHTML
 * representation returned by Tika as SAX events
 ***/

public class TikaParser implements org.apache.nutch.parse.Parser {

	public static final Logger LOG = LoggerFactory.getLogger(TikaParser.class);

	private static Collection<WebPage.Field> FIELDS = new HashSet<WebPage.Field>();

	static {
		FIELDS.add(WebPage.Field.BASE_URL);
		FIELDS.add(WebPage.Field.CONTENT_TYPE);
	}

	private Configuration conf;
	private TikaConfig tikaConfig = null;
	private DOMContentUtils utils;
	private ParseFilters htmlParseFilters;
	private String cachingPolicy;

	public static Charset charset = Charset.forName("UTF-8");
	public static CharsetEncoder encoder = charset.newEncoder();
	public static CharsetDecoder decoder = charset.newDecoder();

	public static ByteBuffer toByteBUffer(String msg) {
		try {
			encoder.reset();
			return encoder.encode(CharBuffer.wrap(msg));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static String toString(ByteBuffer buffer) {
		String data = "";
		try {
			int old_position = buffer.position();
			decoder.reset();
			data = decoder.decode(buffer).toString();
			// reset buffer's position to its original so it is not altered:
			buffer.position(old_position);
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
		return data;
	}

	private String encodeFBUrl(String url) throws UnsupportedEncodingException {
		if (url.indexOf("graph.facebook") > 0) {
			String access_token_string = "access_token=";
			int index = url.indexOf(access_token_string);
			int access_token_end_index = url.indexOf('&');
			if (access_token_end_index < 0)
				access_token_end_index = url.length();
			if (index > 0) {
				String prefix = url.substring(0, index
						+ access_token_string.length());
				String suffix = url.substring(index
						+ access_token_string.length(), access_token_end_index);
				String rest = url.substring(access_token_end_index);
				url = prefix + URLEncoder.encode(suffix, "UTF-8") + rest;
			}
		}
		return url;
	}

	private String decodeFbUrl(String url) throws UnsupportedEncodingException {
		if (url.indexOf("graph.facebook") > 0) {
			String access_token_string = "access_token=";
			int index = url.indexOf(access_token_string);
			if (index > 0) {
				String prefix = url.substring(0, index
						+ access_token_string.length());
				String suffix = url.substring(index
						+ access_token_string.length());
				url = prefix + URLDecoder.decode(suffix, "UTF-8");
			}
		}
		return url;
	}

	@Override
	public Parse getParse(String url, WebPage page) {

		String baseUrl = TableUtil.toString(page.getBaseUrl());
		URL base;
		try {
			base = new URL(baseUrl);
		} catch (MalformedURLException e) {
			return ParseStatusUtils.getEmptyParse(e, getConf());
		}

		// get the right parser using the mime type as a clue
		String mimeType = page.getContentType().toString();
		Parser parser = tikaConfig.getParser(mimeType);
		byte[] raw = page.getContent().array();
		boolean skip = false;
		if (url.indexOf("graph.facebook") > 0) {
			skip = true;
		}

		if (parser == null && !skip) {
			String message = "Can't retrieve Tika parser for mime-type "
					+ mimeType;
			LOG.error(message);
			return ParseStatusUtils.getEmptyParse(
					ParseStatusCodes.FAILED_EXCEPTION, message, getConf());
		}

		Parse parse = null;
		if (skip) {
			System.err.println("USING:" + url);
			ByteBuffer buffer = page.getContent();
			String result = toString(buffer);
			System.err.println(result);
			JSONObject json = null;
			try {
				json = new JSONObject(result);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			if (json.has("paging")) {
				JSONObject next = null;
				try {
					next = (JSONObject) json.get("paging");
				} catch (JSONException e) {
					e.printStackTrace();
				}
				String nextUrl = null;
				try {
					nextUrl = (String) next.get("next");
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				if (nextUrl.length() != 0) {
					try {
						nextUrl = decodeFbUrl(nextUrl);
					} catch (UnsupportedEncodingException e) {
						e.printStackTrace();
					}
					System.out.println("NEXT:" + nextUrl);
				}
				Outlink[] link = new Outlink[1];
				try {
					link[0] = new Outlink(nextUrl,"");
				} catch (MalformedURLException e) {
					e.printStackTrace();
				}
				parse = new Parse("fb text", "fb title", link, ParseStatusUtils.STATUS_SUCCESS);
			}

		} else {
			LOG.debug("Using Tika parser " + parser.getClass().getName()
					+ " for mime-type " + mimeType);

			Metadata tikamd = new Metadata();

			HTMLDocumentImpl doc = new HTMLDocumentImpl();
			doc.setErrorChecking(false);
			DocumentFragment root = doc.createDocumentFragment();
			DOMBuilder domhandler = new DOMBuilder(doc, root);
			ParseContext context = new ParseContext();
			// to add once available in Tika
			// context.set(HtmlMapper.class, IdentityHtmlMapper.INSTANCE);
			try {
				parser.parse(new ByteArrayInputStream(raw), domhandler, tikamd,
						context);
			} catch (Exception e) {
				LOG.error("Error parsing " + url, e);
				return ParseStatusUtils.getEmptyParse(e, getConf());
			}

			HTMLMetaTags metaTags = new HTMLMetaTags();
			String text = "";
			String title = "";
			Outlink[] outlinks = new Outlink[0];

			// we have converted the sax events generated by Tika into a DOM
			// object
			// so we can now use the usual HTML resources from Nutch
			// get meta directives
			HTMLMetaProcessor.getMetaTags(metaTags, root, base);
			if (LOG.isTraceEnabled()) {
				LOG.trace("Meta tags for " + base + ": " + metaTags.toString());
			}

			// check meta directives
			if (!metaTags.getNoIndex()) { // okay to index
				StringBuffer sb = new StringBuffer();
				if (LOG.isTraceEnabled()) {
					LOG.trace("Getting text...");
				}
				utils.getText(sb, root); // extract text
				text = sb.toString();
				sb.setLength(0);
				if (LOG.isTraceEnabled()) {
					LOG.trace("Getting title...");
				}
				utils.getTitle(sb, root); // extract title
				title = sb.toString().trim();
			}

			if (!metaTags.getNoFollow()) { // okay to follow links
				ArrayList<Outlink> l = new ArrayList<Outlink>(); // extract
				// outlinks
				URL baseTag = utils.getBase(root);
				if (LOG.isTraceEnabled()) {
					LOG.trace("Getting links...");
				}
				utils.getOutlinks(baseTag != null ? baseTag : base, l, root);
				outlinks = l.toArray(new Outlink[l.size()]);
				if (LOG.isTraceEnabled()) {
					LOG.trace("found " + outlinks.length + " outlinks in "
							+ base);
				}
			}

			// populate Nutch metadata with Tika metadata
			String[] TikaMDNames = tikamd.names();
			for (String tikaMDName : TikaMDNames) {
				if (tikaMDName.equalsIgnoreCase(Metadata.TITLE))
					continue;
				// TODO what if multivalued?
				page.putToMetadata(new Utf8(tikaMDName), ByteBuffer.wrap(Bytes
						.toBytes(tikamd.get(tikaMDName))));
			}

			// no outlinks? try OutlinkExtractor e.g works for mime types where
			// no
			// explicit markup for anchors

			if (outlinks.length == 0) {
				outlinks = OutlinkExtractor.getOutlinks(text, getConf());
			}

			ParseStatus status = ParseStatusUtils.STATUS_SUCCESS;
			if (metaTags.getRefresh()) {
				status.setMinorCode(ParseStatusCodes.SUCCESS_REDIRECT);
				status
						.addToArgs(new Utf8(metaTags.getRefreshHref()
								.toString()));
				status.addToArgs(new Utf8(Integer.toString(metaTags
						.getRefreshTime())));
			}

			parse = new Parse(text, title, outlinks, status);
			parse = htmlParseFilters.filter(url, page, parse, metaTags, root);

			if (metaTags.getNoCache()) { // not okay to cache
				page.putToMetadata(new Utf8(Nutch.CACHING_FORBIDDEN_KEY),
						ByteBuffer.wrap(Bytes.toBytes(cachingPolicy)));
			}
		}
		return parse;
	}

	public void setConf(Configuration conf) {
		this.conf = conf;
		this.tikaConfig = null;

		try {
			tikaConfig = TikaConfig.getDefaultConfig();
		} catch (Exception e2) {
			String message = "Problem loading default Tika configuration";
			LOG.error(message, e2);
			throw new RuntimeException(e2);
		}

		this.htmlParseFilters = new ParseFilters(getConf());
		this.utils = new DOMContentUtils(conf);
		this.cachingPolicy = getConf().get("parser.caching.forbidden.policy",
				Nutch.CACHING_FORBIDDEN_CONTENT);
	}

	public TikaConfig getTikaConfig() {
		return this.tikaConfig;
	}

	public Configuration getConf() {
		return this.conf;
	}

	@Override
	public Collection<Field> getFields() {
		return FIELDS;
	}

	// main class used for debuggin
	public static void main(String[] args) throws Exception {
		String name = args[0];
		String url = "file:" + name;
		File file = new File(name);
		byte[] bytes = new byte[(int) file.length()];
		DataInputStream in = new DataInputStream(new FileInputStream(file));
		in.readFully(bytes);
		Configuration conf = NutchConfiguration.create();
		// TikaParser parser = new TikaParser();
		// parser.setConf(conf);
		WebPage page = new WebPage();
		page.setBaseUrl(new Utf8(url));
		page.setContent(ByteBuffer.wrap(bytes));
		MimeUtil mimeutil = new MimeUtil(conf);
		MimeType mtype = mimeutil.getMimeType(file);
		page.setContentType(new Utf8(mtype.getName()));
		// Parse parse = parser.getParse(url, page);

		Parse parse = new ParseUtil(conf).parse(url, page);

		System.out.println("content type: " + mtype.getName());
		System.out.println("title: " + parse.getTitle());
		System.out.println("text: " + parse.getText());
		System.out.println("outlinks: " + Arrays.toString(parse.getOutlinks()));
	}
}
