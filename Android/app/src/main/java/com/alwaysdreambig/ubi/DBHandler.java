package com.alwaysdreambig.ubi;

import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.ParseException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;


/**
 * Created by andreamontanari on 25/07/14.
 */
public class DBHandler {


        JSONArray jsonArray = null;

        int code;

        String name, surname, page, mail, lastpost, picture, bio, sex, bday, lat, lng;

        InputStream is = null;
        String result = null;
        String line = null;


        public void insert() {

            new InsertAsyncTask().execute("http://alwaysdreambig.altervista.org/insertUtenti.php");
        }

        public void get() {

            new HttpAsyncTask().execute("http://alwaysdreambig.altervista.org/request.php");
        }

        public void update() {
            new UpdateAsyncTask().execute("http://alwaysdreambig.altervista.org/update.php");
        }

        public static String GET(String url) {
            InputStream inputStream = null;
            String result = "";
            try {
                // create HttpClient
                HttpClient httpclient = new DefaultHttpClient();
                Log.d("CLIENT", httpclient.toString());

                // make GET request to the given URL
                HttpResponse httpResponse = httpclient.execute(new HttpGet(url));
                Log.d("RESPONSE", httpResponse.toString());
                // receive response as inputStream
                inputStream = httpResponse.getEntity().getContent();
                Log.d("STREAM", inputStream.toString());
                // convert inputstream to string
                if (inputStream != null)
                    result = convertInputStreamToString(inputStream);
                else
                    result = "Did not work!";

            } catch (Exception e) {
                Log.d("InputStream", e.getLocalizedMessage());
            }

            return result;
        }


        private static String convertInputStreamToString(InputStream inputStream) throws IOException {
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
            String line = "";
            String result = "";
            while ((line = bufferedReader.readLine()) != null)
                result += line;

            inputStream.close();
            return result;

        }


        public class HttpAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... urls) {

                return GET(urls[0]);
            }

            // onPostExecute displays the results of the AsyncTask.
            @Override
            protected void onPostExecute(String result) {
                Log.d("Message", "Received");
                String jsonString = result;

                try {
                    //Turn the JSON string into an array of JSON objects
                    jsonArray = new JSONArray(jsonString);
                    JSONObject jsonObject = null;

                    for (int i = 0; i < jsonArray.length(); i++) {
                        jsonObject = jsonArray.getJSONObject(i);

                        String id = jsonObject.getString("id");
                        String name = jsonObject.getString("name");
                        String surname = jsonObject.getString("surname");
                        String lat = jsonObject.getString("lat");
                        String lng = jsonObject.getString("lng");
                        String email = jsonObject.getString("mail");
                        String lastpost = jsonObject.getString("lastpost");
                        String picture = jsonObject.getString("picture");


                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
        }


        public class InsertAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... urls) {

                return INSERT(urls[0]);
            }
        }

        public String INSERT(String url) {
            if (LoginActivity.loginname != null) {
                name = LoginActivity.loginname;
                mail = LoginActivity.loginmail;
                lastpost = LoginActivity.loginpost;
                picture = LoginActivity.loginpic;
                page = LoginActivity.loginurl;
                bio = LoginActivity.loginbio;
                bday = LoginActivity.loginbday;
                sex = LoginActivity.loginsex;

                Log.d("PROVA", name + " "+picture);

                ArrayList<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
                nameValuePairs.add(new BasicNameValuePair("name", name));
                nameValuePairs.add(new BasicNameValuePair("surname", surname));
                nameValuePairs.add(new BasicNameValuePair("mail", mail));
                nameValuePairs.add(new BasicNameValuePair("lastpost", lastpost));
                nameValuePairs.add(new BasicNameValuePair("picture", picture));
                nameValuePairs.add(new BasicNameValuePair("URL", page));
                nameValuePairs.add(new BasicNameValuePair("bio", bio));
                nameValuePairs.add(new BasicNameValuePair("bday", bday));
                nameValuePairs.add(new BasicNameValuePair("sex", sex));



                try {
                    HttpClient httpclient = new DefaultHttpClient();
                    HttpPost httppost = new HttpPost(url);
                    httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
                    HttpResponse response = httpclient.execute(httppost);
                    HttpEntity entity = response.getEntity();
                    is = entity.getContent();
                    Log.e("pass 1", "connection success ");
                } catch (Exception e) {
                    Log.e("Fail 1", e.toString());
                }

                try {
                    BufferedReader reader = new BufferedReader
                            (new InputStreamReader(is, "iso-8859-1"), 8);
                    StringBuilder sb = new StringBuilder();
                    while ((line = reader.readLine()) != null) {
                        sb.append(line + "\n");
                    }
                    is.close();
                    result = sb.toString();
                    Log.e("Insert - pass 2", "connection success ");
                } catch (Exception e) {
                    Log.e("Insert - Fail 2", e.toString());
                }

                try {

                    JSONObject json_data = new JSONObject(result);
                    code = (json_data.getInt("code"));

                    if (code == 1) {
                        //Toast.makeText(getBaseContext(), "Inserted Successfully",
                        //Toast.LENGTH_SHORT).show();
                        Log.d("PROVA", "inserted");
                    } else {
                        //Toast.makeText(getBaseContext(), "Sorry, Try Again",
                        //  Toast.LENGTH_LONG).show();
                        Log.d("PROVA", "not inserted, try again");
                    }
                } catch (Exception e) {
                    Log.e("Insert - Fail 3", e.toString());
                }
            }
            return "Okay";

        }

    public class UpdateAsyncTask extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... urls) {

            return UPDATE(urls[0]);
        }
    }

    public String UPDATE(String url) {

        mail = "andrea.montanari92@gmail.com";
        lastpost = "ciao";                      //LoginActivity.loginLastpost;
        //Log.d("lastpost", lastpost);
        lat = Double.toString(MapActivity.latitude);
        lng = Double.toString(MapActivity.longitude);


        ArrayList<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
        nameValuePairs.add(new BasicNameValuePair("mail", mail));
        nameValuePairs.add(new BasicNameValuePair("lat", lat));
        nameValuePairs.add(new BasicNameValuePair("lng", lng));
        nameValuePairs.add(new BasicNameValuePair("lastpost", lastpost));


        try {
            HttpClient httpclient = new DefaultHttpClient();
            HttpPost httppost = new HttpPost(url);
            httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
            HttpResponse response = httpclient.execute(httppost);
            HttpEntity entity = response.getEntity();
            is = entity.getContent();
            Log.e("Update - pass 1", "connection success ");
        } catch (Exception e) {
            Log.e("Update - Fail 1", e.toString());
        }

        try {
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader(is, "iso-8859-1"), 8);
            StringBuilder sb = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
            is.close();
            result = sb.toString();
            Log.e("Update - pass 2", "connection success ");
        } catch (Exception e) {
            Log.e("Update - Fail 2", e.toString());
        }

        try {

            JSONObject json_data = new JSONObject(result);
            code = (json_data.getInt("code"));

            if (code == 1) {
                //Toast.makeText(getBaseContext(), "Inserted Successfully",
                //Toast.LENGTH_SHORT).show();
                Log.d("PROVA", "inserted");
            } else {
                //Toast.makeText(getBaseContext(), "Sorry, Try Again",
                //  Toast.LENGTH_LONG).show();
                Log.d("PROVA", "not updated, try again");
            }
        } catch (Exception e) {
            Log.e("Update - Fail 3", e.toString());
        }
        new HttpAsyncTask().execute("http://alwaysdreambig.altervista.org/request.php");
        return "Okay";
    }

 }

