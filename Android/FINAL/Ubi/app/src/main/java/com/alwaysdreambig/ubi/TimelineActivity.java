package com.alwaysdreambig.ubi;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Layout;
import android.util.Log;
import android.view.Display;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.view.ViewGroup.LayoutParams;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.sql.Time;
import java.util.ArrayList;


public class TimelineActivity extends Activity {

    ArrayList<String> users = MapActivity.users;

    String username, usersurname, userlastPost, userpicture, useremail;

    JSONArray jsonUser = null;
    Bitmap icon = null;

    RelativeLayout rl1,rl2;
    ScrollView sv;
    Status s;
    Button[] b;
    int sum=30;
    ProgressBar pb;

    boolean Load = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timeline);

        if (!Load) {

            Display display = getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            int width = size.x;
            int height = size.y - (width/4);

            rl1 = (RelativeLayout) findViewById(R.id.rl);
            sv = new ScrollView(this); //modifica parametri MATCH PARENT
            sv.setLayoutParams(new ScrollView.LayoutParams(width,height));
            //ScrollView.LayoutParams sp = new ScrollView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT-50);
            //sv.setLayoutParams(sp);
            rl2 = new RelativeLayout(this);
            b = new Button[20];  //modificare qui
            pb = (ProgressBar) findViewById(R.id.prog);

            for (String i : users) {
                new UserAsyncTask().execute(i);
            }
            pb.setVisibility(View.INVISIBLE);
            Log.d("TL", "ho finito di scaricare i dati");
            sv.addView(rl2);
            rl1.addView(sv);
            Log.d("TL", "aggiunta la scrollview al relative layout");
        }

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.login, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public String GETS(String email) {

        InputStream inputStream = null;
        String result = "";
        try {
            // create HttpClient
            HttpClient httpclient = new DefaultHttpClient();
            Log.d("CLIENT", httpclient.toString());

            String emailValue = URLEncoder.encode(email, "UTF-8");

            String URL = "http://www.rambodrahmani.com/Ubi/android/requestUtenti.php?Email="+emailValue;

            HttpGet httpGet = new HttpGet(URL);

            // make GET request to the given URL
            HttpResponse httpResponse = httpclient.execute(httpGet);
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


    public class UserAsyncTask extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... email) {

            return GETS(email[0]);
        }

        // onPostExecute displays the results of the AsyncTask.
        @Override
        protected void onPostExecute(String result) {
            String jsonString = result;

            try {
                //Turn the JSON string into an array of JSON objects
                jsonUser = new JSONArray(jsonString);
                JSONObject jsonObject = null;

                jsonObject = jsonUser.getJSONObject(0);

                useremail = jsonObject.getString("Email");
                username = jsonObject.getString("Nome");
                usersurname = jsonObject.getString("Cognome");
                userlastPost = jsonObject.getString("LastPost");
                userpicture = jsonObject.getString("ProfilePic");

                s = new com.alwaysdreambig.ubi.Status(TimelineActivity.this);
                s.setVisibility(View.INVISIBLE);

                TextView name = (TextView) s.findViewById(R.id.name);
                name.setText(username+" "+usersurname);

                   TextView post = (TextView) s.findViewById(R.id.lastpost);
                   if (userlastPost.length() > 25) {
                        String temp = userlastPost.substring(0, 22);
                        temp = temp.concat("...");
                       post.setText(temp);
                   } else {
                       post.setText(userlastPost);
                   }

                   ImageView profilepic = (ImageView) s.findViewById(R.id.profilePic);
                   profilepic.setImageBitmap(loadImageFromStorage(useremail));

                   RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                            (int) LayoutParams.WRAP_CONTENT, (int) LayoutParams.WRAP_CONTENT);

                    params.leftMargin = 10;
                    params.rightMargin = 10;
                    params.topMargin = sum;
                    params.bottomMargin = sum;
                    //b[i].setText("Button " + i);
                    s.setLayoutParams(params);
                    rl2.addView(s);
                    pb.setVisibility(View.INVISIBLE);
                    s.setVisibility(View.VISIBLE);
                    sum = sum + 200;
                    Load = true;


            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }


    private Bitmap loadImageFromStorage(String title)
    {
        Bitmap b = null;
        try {
            ContextWrapper cw = new ContextWrapper(getApplicationContext());
            File directory = cw.getDir("images", Context.MODE_PRIVATE);
            File f=new File(directory, title+".png");
            b = BitmapFactory.decodeStream(new FileInputStream(f));
            return b;
        }
        catch (FileNotFoundException e)
        {
            e.printStackTrace();
        }
        return b;
    }

    private class ImageDownloader extends AsyncTask<String, Void, Bitmap> {

        @Override
        protected Bitmap doInBackground(String... params) {
            return downloadBitmap(params[0]);
        }

        @Override
        protected void onPreExecute() {
            Log.i("Async-Example", "onPreExecute Called");
        }

        protected void onPostExecute(Bitmap result) {
            Log.i("Async-Example", "onPostExecute Called");
        }

        private Bitmap downloadBitmap(String url) {
            // initialize the default HTTP client object
            final DefaultHttpClient client = new DefaultHttpClient();

            //forming a HttoGet request
            final HttpGet getRequest = new HttpGet(url);
            try {

                HttpResponse response = client.execute(getRequest);

                //check 200 OK for success
                final int statusCode = response.getStatusLine().getStatusCode();

                if (statusCode != HttpStatus.SC_OK) {
                    Log.w("ImageDownloader", "Error " + statusCode +
                            " while retrieving bitmap from " + url);
                    return null;

                }

                final HttpEntity entity = response.getEntity();
                if (entity != null) {
                    InputStream inputStream = null;
                    try {
                        // getting contents from the stream
                        inputStream = entity.getContent();

                        // decoding stream data back into image Bitmap that android understands
                        final Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                        icon = Bitmap.createScaledBitmap(bitmap, 150, 150, false);
                        Log.d("PROVA", "icon creato");
                        return bitmap;
                    } finally {
                        if (inputStream != null) {
                            inputStream.close();
                        }
                        entity.consumeContent();
                    }
                }
            } catch (Exception e) {
                // You Could provide a more explicit error message for IOException
                getRequest.abort();
                Log.e("ImageDownloader", "Something went wrong while" +
                        " retrieving bitmap from " + url + e.toString());
            }

            return null;
        }
    }

    public void onPause() {
        super.onPause();

    }

    public void onResume() {
        super.onResume();
        sv.scrollTo(0,0);
        //setContentView(R.layout.activity_timeline);
    }

}
