package com.hisab.common;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.Charset;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.springframework.beans.factory.annotation.Value;


public class HttpUtility
{

	  @Value("${Proxy.proxySet}")
	  private static boolean applyProxy;
		
		public static String[] httpPost(String URL,String payLoad, boolean AuthReq, String token)
		{
			String contentLength = Integer.toString(payLoad.toString().getBytes().length);
			String responseArr[] = new String[2];
			int ConResponse = 0;
			String ConMsg = null;
			InputStream is = null;
			System.out.println("Data: " + payLoad);
			System.out.println("Content Length: " + contentLength);
			StringBuilder sb = new StringBuilder();
			try
			{
				

				TrustManager[] trustAllCerts = new TrustManager[]
				{ new X509TrustManager()
				{
					public java.security.cert.X509Certificate[] getAcceptedIssuers()
					{
						return null;
					}

					public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType)
					{
					}

					public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType)
					{
					}
				} };
				try
				{

					SSLContext sc = SSLContext.getInstance("SSL");
					sc.init(null, trustAllCerts, new java.security.SecureRandom());
					HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
				} catch (Exception e)
				{
					System.out.println("SSL Error: " + e.getMessage());
					responseArr[0] = e.getMessage();
					responseArr[1] = e.getMessage();
				}

				URL	url = new URL(URL);
				

				System.out.println("Posted URL: " + URL);
				System.out.println("payLoad: "+payLoad.toString());
				HttpURLConnection connection=null;
						connection = (HttpURLConnection) url.openConnection();
				
				connection.setDoOutput(true);
				connection.setRequestMethod("POST");
				connection.setRequestProperty("Connection", "close");
				connection.setRequestProperty("Content-Type", "application/json");
				connection.setRequestProperty("Content-Length", "" + contentLength);
				connection.setRequestProperty("Accept", "application/json");
				if (AuthReq)
				{
					connection.setRequestProperty("Authorization",  token);
				}
	
				connection.setConnectTimeout(100000);
				try
				{
					connection.connect();

				} catch (Exception ex)
				{
					System.out.println("Connection Error: " + ex.getMessage());
					responseArr[0] = ex.toString();
					responseArr[1] = ex.getMessage();
					return responseArr;
				}
					System.out.println("Connected, Preparing to post data.....");
					System.out.println("inside data to post :  " + payLoad.toString());
					try
					{
						OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream());
						wr.write(payLoad.toString());
						wr.flush();
						wr.close();
					} catch (Exception ex)
					{
						ex.printStackTrace();
					}
				
				ConResponse = connection.getResponseCode();
				System.out.println("Connection Response Code: " + ConResponse);
				if (ConResponse != 200 && ConResponse != 201)
				{

					ConResponse = connection.getResponseCode();
					ConMsg = connection.getResponseMessage();
					is = connection.getErrorStream();

					System.out.println("Request Error: " + ConMsg);
					System.out.println("Error: " + connection.getErrorStream());
					responseArr[0] = String.valueOf(ConResponse);
					responseArr[1] = ConMsg;// is.toString();
					System.out.println("Connection Error, Return to update Status");
					return responseArr;
				}

				System.out.println("Connection Response: " + ConMsg);

				System.out.println("Server Respose CODE=" + connection.getResponseCode());
				BufferedReader br = new BufferedReader(
						new InputStreamReader(connection.getInputStream(), Charset.forName("UTF-8")));

				String output;
				System.out.println("Reading response from server.....");
				while ((output = br.readLine()) != null)
				{
					sb.append(output);
				}
				String response = sb.toString();
				responseArr[0] = String.valueOf(ConResponse);
				responseArr[1] = response;

			} catch (MalformedURLException e)
			{
				responseArr[0] = String.valueOf(ConResponse);
				responseArr[1] = e.toString();
				return responseArr;
			} catch (IOException e)
			{
				responseArr[0] = String.valueOf(ConResponse);
				responseArr[1] = e.toString();
				return responseArr;
			} catch (Exception e)
			{
				responseArr[0] = String.valueOf(ConResponse);
				responseArr[1] = e.toString();
				return responseArr;
			}
			System.out.println("Server Respose=" + responseArr[1]);
			return responseArr;
		}
		
		public static String[] httpGet(
		        String URL,
		        boolean authReq,
		        String token) {

		    String responseArr[] = new String[2];

		    int conResponse = 0;

		    InputStream is = null;

		    StringBuilder sb = new StringBuilder();

		    try {

		        TrustManager[] trustAllCerts =
		                new TrustManager[] {

		            new X509TrustManager() {

		                public java.security.cert.X509Certificate[]
		                getAcceptedIssuers() {
		                    return null;
		                }

		                public void checkClientTrusted(
		                        java.security.cert.X509Certificate[] certs,
		                        String authType) {
		                }

		                public void checkServerTrusted(
		                        java.security.cert.X509Certificate[] certs,
		                        String authType) {
		                }
		            }
		        };

		        try {

		            SSLContext sc =
		                    SSLContext.getInstance("SSL");

		            sc.init(
		                    null,
		                    trustAllCerts,
		                    new java.security.SecureRandom());

		            HttpsURLConnection
		                    .setDefaultSSLSocketFactory(
		                            sc.getSocketFactory());

		        } catch (Exception e) {

		            System.out.println(
		                    "SSL Error: " + e.getMessage());

		            responseArr[0] = e.getMessage();
		            responseArr[1] = e.getMessage();

		            return responseArr;
		        }

		        URL url = new URL(URL);

		        System.out.println("GET URL: " + URL);

		        HttpURLConnection connection =
		                (HttpURLConnection) url.openConnection();

		        connection.setRequestMethod("GET");

		        connection.setRequestProperty(
		                "Connection",
		                "close");

		        connection.setRequestProperty(
		                "Accept",
		                "application/json");

		        if (authReq) {

		            connection.setRequestProperty(
		                    "Authorization",
		                    token);
		        }

		        connection.setConnectTimeout(100000);

		        try {

		            connection.connect();

		        } catch (Exception ex) {

		            System.out.println(
		                    "Connection Error: "
		                            + ex.getMessage());

		            responseArr[0] = ex.toString();
		            responseArr[1] = ex.getMessage();

		            return responseArr;
		        }

		        conResponse = connection.getResponseCode();

		        System.out.println(
		                "Connection Response Code: "
		                        + conResponse);

		        if (conResponse != 200
		                && conResponse != 201) {

		            is = connection.getErrorStream();

		            BufferedReader br =
		                    new BufferedReader(
		                            new InputStreamReader(
		                                    is,
		                                    Charset.forName("UTF-8")));

		            String output;

		            while ((output = br.readLine()) != null) {

		                sb.append(output);
		            }

		            responseArr[0] =
		                    String.valueOf(conResponse);

		            responseArr[1] =
		                    sb.toString();

		            return responseArr;
		        }

		        BufferedReader br =
		                new BufferedReader(
		                        new InputStreamReader(
		                                connection.getInputStream(),
		                                Charset.forName("UTF-8")));

		        String output;

		        while ((output = br.readLine()) != null) {

		            sb.append(output);
		        }

		        responseArr[0] =
		                String.valueOf(conResponse);

		        responseArr[1] =
		                sb.toString();

		    } catch (MalformedURLException e) {

		        responseArr[0] =
		                String.valueOf(conResponse);

		        responseArr[1] = e.toString();

		        return responseArr;

		    } catch (IOException e) {

		        responseArr[0] =
		                String.valueOf(conResponse);

		        responseArr[1] = e.toString();

		        return responseArr;

		    } catch (Exception e) {

		        responseArr[0] =
		                String.valueOf(conResponse);

		        responseArr[1] = e.toString();

		        return responseArr;
		    }

		    System.out.println(
		            "Server Response = "
		                    + responseArr[1]);

		    return responseArr;
		}

	
	
	

}
