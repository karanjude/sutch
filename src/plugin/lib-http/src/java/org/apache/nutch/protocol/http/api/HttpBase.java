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
package org.apache.nutch.protocol.http.api;

// JDK imports
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHttpResponse;
import org.apache.http.util.EntityUtils;
import org.apache.nutch.metadata.Metadata;
import org.apache.nutch.metadata.SpellCheckedMetadata;
import org.apache.nutch.net.protocols.Response;
import org.apache.nutch.protocol.Content;
import org.apache.nutch.protocol.Protocol;
import org.apache.nutch.protocol.ProtocolException;
import org.apache.nutch.protocol.ProtocolOutput;
import org.apache.nutch.protocol.ProtocolStatusCodes;
import org.apache.nutch.protocol.ProtocolStatusUtils;
import org.apache.nutch.protocol.RobotRules;
import org.apache.nutch.storage.WebPage;
import org.apache.nutch.util.GZIPUtils;
import org.apache.nutch.util.DeflateUtils;
import org.apache.nutch.util.LogUtil;
import org.apache.nutch.util.MimeUtil;

import twitter4j.Paging;
import twitter4j.ResponseList;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.conf.ConfigurationBuilder;

/**
 * @author J&eacute;r&ocirc;me Charron
 */
public abstract class HttpBase implements Protocol {

	public static final int BUFFER_SIZE = 8 * 1024;

	private static final byte[] EMPTY_CONTENT = new byte[0];

	private RobotRulesParser robots = null;

	/** The proxy hostname. */
	protected String proxyHost = null;

	/** The proxy port. */
	protected int proxyPort = 8080;

	/** Indicates if a proxy is used */
	protected boolean useProxy = false;

	/** The network timeout in millisecond */
	protected int timeout = 10000;

	/** The length limit for downloaded content, in bytes. */
	protected int maxContent = 64 * 1024;

	/** The Nutch 'User-Agent' request header */
	protected String userAgent = getAgentString("NutchCVS", null, "Nutch",
			"http://lucene.apache.org/nutch/bot.html",
			"nutch-agent@lucene.apache.org");

	/** The "Accept-Language" request header value. */
	protected String acceptLanguage = "en-us,en-gb,en;q=0.7,*;q=0.3";

	/** The default logger */
	private final static Logger LOGGER = LoggerFactory
			.getLogger(HttpBase.class);

	/** The specified logger */
	private Logger logger = LOGGER;

	/** The nutch configuration */
	private Configuration conf = null;

	private MimeUtil mimeTypes;

	/** Do we use HTTP/1.1? */
	protected boolean useHttp11 = false;

	/** Creates a new instance of HttpBase */
	public HttpBase() {
		this(null);
	}

	/** Creates a new instance of HttpBase */
	public HttpBase(Logger logger) {
		if (logger != null) {
			this.logger = logger;
		}
		robots = new RobotRulesParser();
	}

	public static Charset charset = Charset.forName("UTF-8");
	public static CharsetEncoder encoder = charset.newEncoder();
	public static CharsetDecoder decoder = charset.newDecoder();

	private String host;

	private Response response;

	private byte[] contents;

	private URL u;

	private int code;

	private Content c;

	private String contentType;

	private Metadata headers;

	public static ByteBuffer toByteBUffer(String msg) throws CharacterCodingException {
			encoder.reset();
			return encoder.encode(CharBuffer.wrap(msg));
	}

	// Inherited Javadoc
	public void setConf(Configuration conf) {
		this.conf = conf;
		this.proxyHost = conf.get("http.proxy.host");
		this.proxyPort = conf.getInt("http.proxy.port", 8080);
		this.useProxy = (proxyHost != null && proxyHost.length() > 0);
		this.timeout = conf.getInt("http.timeout", 10000);
		this.maxContent = conf.getInt("http.content.limit", 64 * 1024);
		this.userAgent = getAgentString(conf.get("http.agent.name"), conf
				.get("http.agent.version"), conf.get("http.agent.description"),
				conf.get("http.agent.url"), conf.get("http.agent.email"));
		this.acceptLanguage = conf.get("http.accept.language", acceptLanguage);
		this.mimeTypes = new MimeUtil(conf);
		this.useHttp11 = conf.getBoolean("http.useHttp11", false);
		this.robots.setConf(conf);
		logConf();
	}

	// Inherited Javadoc
	public Configuration getConf() {
		return this.conf;
	}

	public ProtocolOutput getProtocolOutput(String url, WebPage page) {

		try {
			host = null;
			response = null;
			contents = null;
			u = null;
			code = 0;
			c = null;

			if (url.indexOf("graph.facebook") > 0) {
				url = handleFaceBookContent(url);
			} else if (url.indexOf("api.twitter.com") > 0) {
				try {
					handleTwitterContent(url);
				} catch (TwitterException e) {
					e.printStackTrace(System.err);
					code = e.getStatusCode();
					c = null;
				}
			} else {
				handleSiteContent(url, page);
			}
			// request

			if (code == 200) { // got a good response
				return new ProtocolOutput(c); // return it

			} else if (code == 410) { // page is gone
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.GONE, "Http: " + code + " url="
								+ url));
			} else if (code >= 300 && code < 400) { // handle redirect
				String location = response.getHeader("Location");
				// some broken servers, such as MS IIS, use lowercase header
				// name...
				if (location == null)
					location = response.getHeader("location");
				if (location == null)
					location = "";
				u = new URL(u, location);
				int protocolStatusCode;
				switch (code) {
				case 300: // multiple choices, preferred value in Location
					protocolStatusCode = ProtocolStatusCodes.MOVED;
					break;
				case 301: // moved permanently
				case 305: // use proxy (Location is URL of proxy)
					protocolStatusCode = ProtocolStatusCodes.MOVED;
					break;
				case 302: // found (temporarily moved)
				case 303: // see other (redirect after POST)
				case 307: // temporary redirect
					protocolStatusCode = ProtocolStatusUtils.TEMP_MOVED;
					break;
				case 304: // not modified
					protocolStatusCode = ProtocolStatusUtils.NOTMODIFIED;
					break;
				default:
					protocolStatusCode = ProtocolStatusUtils.MOVED;
				}
				// handle this in the higher layer.
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						protocolStatusCode, u));
			} else if (code == 400) { // bad request, mark as GONE
				if (logger.isTraceEnabled()) {
					logger.trace("400 Bad request: " + u);
				}
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.GONE, u));
			} else if (code == 401) { // requires authorization, but no valid
				// auth provided.
				if (logger.isTraceEnabled()) {
					logger.trace("401 Authentication Required");
				}
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.ACCESS_DENIED,
						"Authentication required: " + url));
			} else if (code == 404) {
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.NOTFOUND, u));
			} else if (code == 410) { // permanently GONE
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.GONE, u));
			} else {
				return new ProtocolOutput(c, ProtocolStatusUtils.makeStatus(
						ProtocolStatusCodes.EXCEPTION, "Http code=" + code
								+ ", url=" + u));
			}
		} catch (Throwable e) {
			e.printStackTrace(LogUtil.getErrorStream(logger));
			return new ProtocolOutput(null, ProtocolStatusUtils.makeStatus(
					ProtocolStatusCodes.EXCEPTION, e.toString()));
		}
	}

	private void handleTwitterContent(String url) throws MalformedURLException,
			TwitterException, UnsupportedEncodingException, CharacterCodingException {
		// url = getTwitterUrl(url);
		getTwitterResponse(url);
		c = storeSiteContent(contents, u, contentType, headers);

	}

	private byte[] updateTwitterContent(HttpResponse response1) {
		// TODO Auto-generated method stub
		return null;
	}

	private HttpResponse getTwitterResponse(String url)
			throws MalformedURLException, TwitterException, UnsupportedEncodingException, CharacterCodingException {
		url = URLDecoder.decode(url, "UTF-8");
		Map<String, String> map = getQueryParams(url);
		String consumerKey = map.get("consumer_key");
		String consumerSecret = map.get("consumer_secret");
		String accessToken = map.get("oauth_key");
		String accessTokenSecret = map.get("oauth_secret");

		Twitter twitter = getTwitterInstance(consumerKey, consumerSecret,
				accessToken, accessTokenSecret);
		Paging paging = new Paging();
		paging.setCount(10);
		twitter4j.internal.http.HttpResponse twitterResponse;
		String result = null;
		if (!(url.indexOf("statuses/show.json") >= 0)) {
			String max_id = map.get("max_id");
			if (null != max_id)
				paging.setMaxId(Long.parseLong(max_id));
			ResponseList<Status> homeTimeline = twitter.getUserTimeline(paging);
			twitterResponse = homeTimeline.getResponse();
			result = twitterResponse.asJSONArray().toString();
		} else {
			String id = map.get("id");
			Long statusId = Long.parseLong(id);
			Status status = twitter.showStatus(statusId);
			twitterResponse = status.getResponse();
			result = twitterResponse.asJSONObject().toString();
		}

		u = new URL(twitterResponse.getRequestURL());
		code = twitterResponse.getStatusCode();
		ByteBuffer buffer = toByteBUffer(result);
		contents = buffer.array();
		contentType = "text/javascript";

		headers = new SpellCheckedMetadata();
		Map<String, List<String>> responseHeaders = twitterResponse
				.getResponseHeaderFields();
		for (String key : responseHeaders.keySet()) {
			List<String> values = responseHeaders.get(key);
			for (String value : values) {
				if (null == key)
					continue;
				if (null == value)
					continue;
				headers.add(key, value);
			}
		}
		return null;
	}

	private Map<String, String> getQueryParams(String url) {
		String query = url.substring(url.indexOf("?") + 1);
		String[] params = query.split("&");
		Map<String, String> map = new HashMap<String, String>();
		for (String param : params) {
			String name = param.split("=")[0];
			String value = param.split("=")[1];
			map.put(name, value);
			System.out.println(name + " " + value);
		}
		return map;
	}

	private Twitter getTwitterInstance(String consumerKey,
			String consumerSecret, String accessToken, String accessTokenSecret) {
		TwitterFactory tf = getTwitterFactoryWithConfigParams(consumerKey,
				consumerSecret, accessToken, accessTokenSecret);

		Twitter twitter = tf.getInstance();
		return twitter;
	}

	private TwitterFactory getTwitterFactoryWithConfigParams(
			String consumerKey, String consumerSecret, String accessToken,
			String accessTokenSecret) {
		ConfigurationBuilder cb = new ConfigurationBuilder();
		cb.setDebugEnabled(true).setOAuthConsumerKey(consumerKey)
				.setOAuthConsumerSecret(consumerSecret).setOAuthAccessToken(
						accessToken).setOAuthAccessTokenSecret(
						accessTokenSecret).setPrettyDebugEnabled(true);
		TwitterFactory tf = new TwitterFactory(cb.build());
		return tf;
	}

	private void handleSiteContent(String url, WebPage page)
			throws MalformedURLException, ProtocolException, IOException {
		u = new URL(url);
		response = getResponse(u, page, false);
		code = response.getCode();
		contents = response.getContent();
		c = new Content(u.toString(), u.toString(),
				(contents == null ? EMPTY_CONTENT : contents), response
						.getHeader("Content-Type"), response.getHeaders(),
				mimeTypes);
	}

	private String handleFaceBookContent(String url)
			throws UnsupportedEncodingException, MalformedURLException,
			IOException, ClientProtocolException {
		url = getFaceBookUrl(url);
		u = new URL(url);

		HttpResponse response1 = getFacebookResponse(url);
		code = response1.getStatusLine().getStatusCode();
		contents = updateFacebookContent(response1);
		contentType = getContentType(response1);
		headers = getHeaders(response1);

		c = storeSiteContent(contents, u, contentType, headers);
		return url;
	}

	private byte[] updateFacebookContent(HttpResponse response1)
			throws IOException {
		byte[] content;
		HttpEntity entity = response1.getEntity();
		ByteBuffer buffer = convertFacebookResponseToByteBuffer(entity);
		content = buffer.array();
		return content;
	}

	private String getContentType(HttpResponse response1) {
		String contentType = response1.getFirstHeader("Content-Type")
				.getValue();
		return contentType;
	}

	private Metadata getHeaders(HttpResponse response1) {
		Metadata headers = new SpellCheckedMetadata();
		Header[] allHeaders = response1.getAllHeaders();
		for (int i = 0; i < allHeaders.length; i++) {
			headers.add(allHeaders[i].getName(), allHeaders[i].getValue());
		}
		return headers;
	}

	private Content storeSiteContent(byte[] content, URL u, String contentType,
			Metadata headers) {
		Content c;
		c = new Content(u.toString(), u.toString(),
				(content == null ? EMPTY_CONTENT : content), contentType,
				headers, mimeTypes);
		return c;
	}

	private ByteBuffer convertFacebookResponseToByteBuffer(HttpEntity entity)
			throws IOException {
		String result = EntityUtils.toString(entity);

		System.err.println(result);
		ByteBuffer buffer = toByteBUffer(result);
		return buffer;
	}

	private HttpResponse getFacebookResponse(String url) throws IOException,
			ClientProtocolException {
		DefaultHttpClient client = new DefaultHttpClient();
		HttpGet get = new HttpGet(url);
		HttpResponse response1 = client.execute(get);
		return response1;
	}

	private String getFaceBookUrl(String url)
			throws UnsupportedEncodingException {
		String access_token_string = "access_token=";
		int index = url.indexOf(access_token_string);
		int access_token_end_index = url.indexOf('&');
		if (access_token_end_index < 0)
			access_token_end_index = url.length();
		if (index > 0) {
			String prefix = url.substring(0, index
					+ access_token_string.length());
			String suffix = url.substring(index + access_token_string.length(),
					access_token_end_index);
			String rest = url.substring(access_token_end_index);
			url = prefix + URLEncoder.encode(suffix, "UTF-8") + rest;
		}
		System.err.println("USING:" + url);
		return url;
	}

	/*
	 * -------------------------- * </implementation:Protocol> *
	 * --------------------------
	 */

	public String getProxyHost() {
		return proxyHost;
	}

	public int getProxyPort() {
		return proxyPort;
	}

	public boolean useProxy() {
		return useProxy;
	}

	public int getTimeout() {
		return timeout;
	}

	public int getMaxContent() {
		return maxContent;
	}

	public String getUserAgent() {
		return userAgent;
	}

	/**
	 * Value of "Accept-Language" request header sent by Nutch.
	 * 
	 * @return The value of the header "Accept-Language" header.
	 */
	public String getAcceptLanguage() {
		return acceptLanguage;
	}

	public boolean getUseHttp11() {
		return useHttp11;
	}

	private static String getAgentString(String agentName, String agentVersion,
			String agentDesc, String agentURL, String agentEmail) {

		if ((agentName == null) || (agentName.trim().length() == 0)) {
			// TODO : NUTCH-258
			if (LOGGER.isErrorEnabled()) {
				LOGGER.error("No User-Agent string set (http.agent.name)!");
			}
		}

		StringBuffer buf = new StringBuffer();

		buf.append(agentName);
		if (agentVersion != null) {
			buf.append("/");
			buf.append(agentVersion);
		}
		if (((agentDesc != null) && (agentDesc.length() != 0))
				|| ((agentEmail != null) && (agentEmail.length() != 0))
				|| ((agentURL != null) && (agentURL.length() != 0))) {
			buf.append(" (");

			if ((agentDesc != null) && (agentDesc.length() != 0)) {
				buf.append(agentDesc);
				if ((agentURL != null) || (agentEmail != null))
					buf.append("; ");
			}

			if ((agentURL != null) && (agentURL.length() != 0)) {
				buf.append(agentURL);
				if (agentEmail != null)
					buf.append("; ");
			}

			if ((agentEmail != null) && (agentEmail.length() != 0))
				buf.append(agentEmail);

			buf.append(")");
		}
		return buf.toString();
	}

	protected void logConf() {
		if (logger.isInfoEnabled()) {
			logger.info("http.proxy.host = " + proxyHost);
			logger.info("http.proxy.port = " + proxyPort);
			logger.info("http.timeout = " + timeout);
			logger.info("http.content.limit = " + maxContent);
			logger.info("http.agent = " + userAgent);
			logger.info("http.accept.language = " + acceptLanguage);
		}
	}

	public byte[] processGzipEncoded(byte[] compressed, URL url)
			throws IOException {

		if (LOGGER.isTraceEnabled()) {
			LOGGER.trace("uncompressing....");
		}

		byte[] content;
		if (getMaxContent() >= 0) {
			content = GZIPUtils.unzipBestEffort(compressed, getMaxContent());
		} else {
			content = GZIPUtils.unzipBestEffort(compressed);
		}

		if (content == null)
			throw new IOException("unzipBestEffort returned null");

		if (LOGGER.isTraceEnabled()) {
			LOGGER.trace("fetched " + compressed.length
					+ " bytes of compressed content (expanded to "
					+ content.length + " bytes) from " + url);
		}
		return content;
	}

	public byte[] processDeflateEncoded(byte[] compressed, URL url)
			throws IOException {

		if (LOGGER.isTraceEnabled()) {
			LOGGER.trace("inflating....");
		}

		byte[] content = DeflateUtils.inflateBestEffort(compressed,
				getMaxContent());

		if (content == null)
			throw new IOException("inflateBestEffort returned null");

		if (LOGGER.isTraceEnabled()) {
			LOGGER.trace("fetched " + compressed.length
					+ " bytes of compressed content (expanded to "
					+ content.length + " bytes) from " + url);
		}
		return content;
	}

	protected static void main(HttpBase http, String[] args) throws Exception {
		@SuppressWarnings("unused")
		boolean verbose = false;
		String url = null;

		String usage = "Usage: Http [-verbose] [-timeout N] url";

		if (args.length == 0) {
			System.err.println(usage);
			System.exit(-1);
		}

		for (int i = 0; i < args.length; i++) { // parse command line
			if (args[i].equals("-timeout")) { // found -timeout option
				http.timeout = Integer.parseInt(args[++i]) * 1000;
			} else if (args[i].equals("-verbose")) { // found -verbose option
				verbose = true;
			} else if (i != args.length - 1) {
				System.err.println(usage);
				System.exit(-1);
			} else
				// root is required parameter
				url = args[i];
		}

		// if (verbose) {
		// LOGGER.setLevel(Level.FINE);
		// }

		ProtocolOutput out = http.getProtocolOutput(url, new WebPage());
		Content content = out.getContent();

		System.out.println("Status: " + out.getStatus());
		if (content != null) {
			System.out.println("Content Type: " + content.getContentType());
			System.out.println("Content Length: "
					+ content.getMetadata().get(Response.CONTENT_LENGTH));
			System.out.println("Content:");
			String text = new String(content.getContent());
			System.out.println(text);
		}

	}

	protected abstract Response getResponse(URL url, WebPage page,
			boolean followRedirects) throws ProtocolException, IOException;

	@Override
	public RobotRules getRobotRules(String url, WebPage page) {
		return robots.getRobotRulesSet(this, url);
	}

}
