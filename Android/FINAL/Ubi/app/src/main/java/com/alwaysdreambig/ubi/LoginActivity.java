package com.alwaysdreambig.ubi;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.pm.Signature;
import android.graphics.Typeface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.http.SslError;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Message;
import android.os.StrictMode;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.util.TypedValue;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.FacebookRequestError;
import com.facebook.HttpMethod;
import com.facebook.LoggingBehavior;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.Settings;
import com.facebook.UiLifecycleHelper;
import com.facebook.model.GraphObject;
import com.facebook.model.GraphUser;
import com.facebook.widget.LoginButton;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesClient;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.plus.PlusClient;
import com.google.android.gms.plus.model.people.Person;
import com.google.android.gms.plus.model.people.PersonBuffer;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import twitter4j.StatusUpdate;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.User;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;

public class LoginActivity extends BarActivity implements
        GooglePlayServicesClient.ConnectionCallbacks, GooglePlayServicesClient.OnConnectionFailedListener, PlusClient.OnPeopleLoadedListener {
    private SharedPreferences sPrefs;

    public static String date, time, dateandtime;

    GPSTracker gps;

    // Dichiarazioni Facebook Login
    public static String fbid, fbmail, fbname, fbsurname, fbpic, fburl, fbpost, fbbio, fbbday, fbsex;
    boolean FacebookLogIn = false;

    private Session.StatusCallback callback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    };

    /* URL saved to be loaded after fb login */
    private static final String target_url="http://www.example.com";
    private static final String target_url_prefix="www.example.com";
    private Context mContext;
    private WebView mWebview;
    private WebView mWebviewPop;
    private FrameLayout mContainer;
    private long mLastBackPressTime = 0;
    private Toast mToast;


    private static final List<String> PERMISSIONS = Arrays.asList(
            "public_profile", "user_friends", "user_status","read_stream", "email","user_about_me");

    private UiLifecycleHelper uiHelper;

    // Dichiarazioni Twitter Login
    /* Shared preference keys */
    private static final String PREF_NAME = "sample_twitter_pref";
    private static final String PREF_KEY_OAUTH_TOKEN = "oauth_token";
    private static final String PREF_KEY_OAUTH_SECRET = "oauth_token_secret";
    private static final String PREF_KEY_TWITTER_LOGIN = "is_twitter_loggedin";
    private static final String PREF_USER_NAME = "twitter_user_name";

    /* Any number for uniquely distinguish your request */
    public static final int WEBVIEW_REQUEST_CODE = 100;

    private static Twitter twitter;
    private static RequestToken requestToken;

    private static SharedPreferences mSharedPreferences;

    private EditText mShareEditText;
    private TextView userName;
    private View loginLayout;
    private View shareLayout;

    private String consumerKey = null;
    private String consumerSecret = null;
    private String callbackUrl = null;
    private String oAuthVerifier = null;

    static final String TWITTER_CALLBACK_URL = "tweet-to-twitter-blundell-01-android:///";

    // Twitter oauth urls
    static final String URL_TWITTER_AUTH = "auth_url";
    static final String URL_TWITTER_OAUTH_VERIFIER = "oauth_verifier";
    static final String URL_TWITTER_OAUTH_TOKEN = "oauth_token";

    boolean TwitterLogin = false;


    View twinfo;

    // Progress dialog
    ProgressDialog pDialog;

    Dialog dialog = null;

    Button btnTwitter;

    public static String twid, twmail, twname, twsurname, twurl, twpic, twpost, twbio, twbday, twsex;


    // Dichiarazione GooglePlus Login
    private static final int RC_SIGN_IN = 0;
    private static final int PROFILE_PIC_SIZE = 400;

    boolean GooglePlusLogIn = false;
    private GoogleApiClient mGoogleApiClient;

    private static final int REQUEST_CODE_RESOLVE_ERR = 9000;

    private ProgressDialog mConnectionProgressDialog;
    private PlusClient mPlusClient;
    private ConnectionResult mConnectionResult;
    Person currentPerson;

    public static String gid, gmail, gname, gsurname, gpic, gurl, gpost, gbio, gbday, gsex;

    //Info login
    public static String loginid;
    public static String loginmail;
    public static String loginname;
    public static String loginsurname;
    public static String loginpic;
    public static String loginurl;
    public static String loginpost;
    public static String loginbio;
    public static String loginbday;
    public static String loginsex;

    //db
    JSONArray jsonArray = null;

    int code;

    String name, surname, page, mail, lastpost, picture, bio, sex, bday, lat, lng;

    InputStream is = null;
    String result = null;
    String line = null;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Imposta la view in modalità full screen.
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.activity_login);

        // Customizzazione della TextView contenente il nome dell'APP
        TextView App_Title = (TextView) findViewById(R.id.app_title);

        Typeface tf = Typeface.createFromAsset(getAssets(), "fonts/Billabong.ttf");
        App_Title.setTypeface(tf);
        App_Title.setTextSize(TypedValue.COMPLEX_UNIT_PX, 200);


        if (isOnline()) {

            gps = new GPSTracker(this);

            if (gps.canGetLocation()) {
                //Facebook Login Setup
                Settings.addLoggingBehavior(LoggingBehavior.INCLUDE_ACCESS_TOKENS);

                Session session = Session.getActiveSession();
                if (session == null) {
                    if (savedInstanceState != null) {
                        session = Session.restoreSession(this, null, callback, savedInstanceState);
                    }
                    if (session == null) {
                        session = new Session(this);
                    }
                    Session.setActiveSession(session);
                    if (session.getState().equals(SessionState.CREATED_TOKEN_LOADED)) {
                        session.openForRead(new Session.OpenRequest(this).setCallback(callback));
                    }
                }


                uiHelper = new UiLifecycleHelper(this, callback);
                uiHelper.onCreate(savedInstanceState);

                if (android.os.Build.VERSION.SDK_INT > 9) {
                    StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
                    StrictMode.setThreadPolicy(policy);
                }

                LoginButton authButton = (LoginButton) findViewById(R.id.btnFb);
                authButton.setReadPermissions(PERMISSIONS);
                Log.d("PROVA", authButton.getText().toString());

                //Twitter Login Setup
                mWebview = (WebView) findViewById(R.id.webview);

                TwitterSetup();


                //Google Plus Login Setup
                mPlusClient = new PlusClient.Builder(this, this, this)
                        .setActions("http://schemas.google.com/AddActivity", "http://schemas.google.com/BuyActivity")
                        .setScopes(Scopes.PLUS_LOGIN, Scopes.PROFILE).build();

                // Barra di avanzamento da visualizzare se l'errore di connessione non viene risolto.
                mConnectionProgressDialog = new ProgressDialog(this);
                mConnectionProgressDialog.setMessage("Signing in...");

        /* PER TROVARE HASH KEY
        try {
            PackageInfo info = getPackageManager().getPackageInfo("com.alwaysdreambig.ubi", PackageManager.GET_SIGNATURES);
            for (Signature signature : info.signatures) {
                MessageDigest md = MessageDigest.getInstance("SHA");
                md.update(signature.toByteArray());
                Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        */

                // Controlliamo se è già stato eseguito il login utilizzando un account.
                sPrefs = getSharedPreferences("com.alwaysdreambig.ubi", MODE_PRIVATE);
                String last_account = sPrefs.getString("LAST_ACCOUNT", null);
                if (last_account != null && !last_account.isEmpty()) {
                    // È stato già eseguito il login con un account: accesso automatico + goToHome
                    if (last_account.contentEquals("facebook")) {
                        Toast.makeText(this, "Ultimo accesso eseguito con Facebook.", Toast.LENGTH_SHORT).show();
                        uiHelper = new UiLifecycleHelper(this, callback);
                        uiHelper.onCreate(savedInstanceState);
                        AccessoFacebook();
                    } else if (last_account.contentEquals("twitter")) {
                        Toast.makeText(this, "Ultimo accesso eseguito con Twitter.", Toast.LENGTH_SHORT).show();

                    } else if (last_account.contentEquals("googleplus")) {
                        Toast.makeText(this, "Ultimo accesso eseguito con Google Plus.", Toast.LENGTH_SHORT).show();
                        GooglePlusLogin();

                    }
                }
            } else {
                Toast.makeText(this, "Please activate your GPS to continue", Toast.LENGTH_SHORT).show();
                gps.showSettingsAlert();
            }
            // In qualsiasi altro caso, non è ancora stato eseguito il login con nessun account.
        } else {
            Toast.makeText(this, "Please connect to internet to continue", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS));
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getMenuInflater().inflate(R.menu.login, menu);
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


    // Inizio Implementazione Facebook Login
    public void FacebookLogin(View v) {

        FacebookLogIn = true;

        Session session = Session.getActiveSession();
        if (!session.isOpened() && !session.isClosed()) {
            session.openForRead(new Session.OpenRequest(this).setCallback(callback));
            Log.d("PROVA", "DUE");

        } else {
            Log.d("PROVA", "UNO");
            //Session.openActiveSession(this, true, callback);
            AccessoFacebook();
        }
    }


    public void AccessoFacebook() {

        Session session = Session.openActiveSession(this, true, new Session.StatusCallback() {
            // callback when session changes state
            @Override
            public void call(Session session, SessionState state, Exception exception) {

                if (session.isOpened()) {

                    List<Request> requests = new ArrayList<Request>();

                    requests.add(
                            // make request to the /me API
                            Request.newMeRequest(session, new Request.GraphUserCallback() {
                                // callback after Graph API response with user object
                                @Override
                                public void onCompleted(GraphUser user, Response response) {
                                    if (user != null) {

                                        fbid = user.getId();
                                        fbname = user.getFirstName();
                                        fbsurname = user.getLastName();
                                        fburl = user.getLink();
                                        fbpic = "https://graph.facebook.com/" + fbid + "/picture?type=large";
                                        fbmail = user.getProperty("email").toString();
                                        fbbio = user.getProperty("bio").toString();
                                        fbbday = user.getBirthday();
                                        fbsex = user.getProperty("gender").toString();

                                        Log.d("FacebookData", "userid: " + fbid);
                                        Log.d("FacebookData", "name: " + fbname);
                                        Log.d("FacebookData","surname: "+fbsurname);
                                        Log.d("FacebookData", "link: " + fburl);
                                        Log.d("FacebookData", "profilepicture: " + fbpic);
                                        Log.d("FacebookData", "mail: " + fbmail);
                                        Log.d("FacebookData", "bday: "+fbbday);
                                        Log.d("FacebookData", "gender: "+fbsex);
                                        Log.d("FacebookData", "bio: "+fbbio);
                                        loginid = fbid;
                                        loginname = fbname;
                                        loginsurname = fbsurname;
                                        loginmail = fbmail;
                                        loginpic = fbpic;
                                        loginurl = fburl;
                                        loginbio = fbbio;
                                        loginbday = fbbday;
                                        loginsex = fbsex;
                                    }
                                }
                            })
                    );


                    final Bundle params = new Bundle();
                    params.putString("fields", "message");

                    //this request is to retrieve the latest post on the wall
                    Request r2 = new Request(session, "me/statuses", params, HttpMethod.GET, new Request.Callback() {


                        public void onCompleted(Response response) {
                            // If the response is successful
                            FacebookRequestError error = response.getError();
                            if (error != null) {
                                Log.i(this.getClass().getName(), "Error retrieving.");
                            } else {
                                GraphObject mygraph = response.getGraphObject();
                                JSONObject innerjson = mygraph.getInnerJSONObject();
                                try {
                                    JSONArray msgarr = innerjson.getJSONArray("data");
                                    JSONObject msgo = msgarr.getJSONObject(0);
                                    fbpost = msgo.optString("message");
                                    loginpost = fbpost;
                                    Log.d("FacebookData", "LastPost: " + fbpost);

                                    if (loginname != null) {
                                        new InsertAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertUtenti.php");
                                        new InsertMapAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertMappa.php");
                                        setLastAccount("facebook");

                                        Intent intent = new Intent(LoginActivity.this, HomeActivity.class);
                                        startActivity(intent);
                                    }

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }

                            }
                        }
                    });

                    requests.add(r2);

                    Request.executeBatchAsync(requests);
                }
            }

        });

    }

    private void onSessionStateChange(Session session, SessionState state, Exception exception) {
        if (state.isOpened()) {
            Log.i("FacebookStatus", "Logged in...");
        } else if (state.isClosed()) {
            Log.i("FacebookStatus", "Logged out...");
            onClickLogout();
        }
    }
    private void onClickLogout() {
        Session session = Session.getActiveSession();
        if (!session.isClosed()) {
            session.closeAndClearTokenInformation();
        }
    }
    // Fine Implementazione Facebook Login



    // Inizio Implementazione Twitter Login

    public void TwitterSetup() {


        /* initializing twitter parameters from string.xml */
        initTwitterConfigs();

            /* Enabling strict mode */
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

            /* Check if required twitter keys are set */
        if (TextUtils.isEmpty(consumerKey) || TextUtils.isEmpty(consumerSecret)) {
            Toast.makeText(this, "Twitter key and secret not configured",
                    Toast.LENGTH_SHORT).show();
            return;
        }

            /* Initialize application preferences */
        mSharedPreferences = getSharedPreferences(PREF_NAME, 0);

        boolean isLoggedIn = mSharedPreferences.getBoolean(PREF_KEY_TWITTER_LOGIN, false);

		/*  if already logged in, then hide login layout and show share layout */
            if (isLoggedIn) {

                String username = mSharedPreferences.getString(PREF_USER_NAME, "");
                Log.d("TW", "ho già fatto l'accesso, si entra!");
                Intent intent = new Intent(this, HomeActivity.class);
                startActivity(intent);

            } else {

                Uri uri = getIntent().getData();

                if (uri != null && uri.toString().startsWith(callbackUrl)) {

                    String verifier = uri.getQueryParameter(oAuthVerifier);

                    try {

					/* Getting oAuth authentication token */
                        AccessToken accessToken = twitter.getOAuthAccessToken(requestToken, verifier);

					/* Getting user id form access token */
                        long userID = accessToken.getUserId();
                        final User user = twitter.showUser(userID);

                        getData(user);

                        /* save updated token */
                        saveTwitterInfo(accessToken);

                    } catch (Exception e) {
                        Log.e("Failed to login Twitter!!", e.getMessage());
                    }
                }

            }
        }


        /**
         * Saving user information, after user is authenticated for the first time.
         * You don't need to show user to login, until user has a valid access toen
         */
    private void saveTwitterInfo(AccessToken accessToken) {

        long userID = accessToken.getUserId();

        User user;
        try {
            user = twitter.showUser(userID);

            String username = user.getName();

			/* Storing oAuth tokens to shared preferences */
            SharedPreferences.Editor e = mSharedPreferences.edit();
            e.putString(PREF_KEY_OAUTH_TOKEN, accessToken.getToken());
            e.putString(PREF_KEY_OAUTH_SECRET, accessToken.getTokenSecret());
            e.putBoolean(PREF_KEY_TWITTER_LOGIN, true);
            e.putString(PREF_USER_NAME, username);
            e.commit();

        } catch (TwitterException e1) {
            e1.printStackTrace();
        }
    }

    /* Reading twitter essential configuration parameters from strings.xml */
    private void initTwitterConfigs() {
        consumerKey = getString(R.string.twitter_consumer_key);
        consumerSecret = getString(R.string.twitter_consumer_secret);
        callbackUrl = getString(R.string.twitter_callback);
        oAuthVerifier = getString(R.string.twitter_oauth_verifier);
    }


    private void loginToTwitter() {
        boolean isLoggedIn = mSharedPreferences.getBoolean(PREF_KEY_TWITTER_LOGIN, false);

        if (!isLoggedIn) {
            final ConfigurationBuilder builder = new ConfigurationBuilder();
            builder.setOAuthConsumerKey(consumerKey);
            builder.setOAuthConsumerSecret(consumerSecret);

            final Configuration configuration = builder.build();
            final TwitterFactory factory = new TwitterFactory(configuration);
            twitter = factory.getInstance();

            try {
                requestToken = twitter.getOAuthRequestToken(callbackUrl);

                /**
                 *  Loading twitter login page on webview for authorization
                 *  Once authorized, results are received at onActivityResult
                 *  */
                final Intent intent = new Intent(this, WebViewActivity.class);
                intent.putExtra(WebViewActivity.EXTRA_URL, requestToken.getAuthenticationURL());
                startActivityForResult(intent, WEBVIEW_REQUEST_CODE);

            } catch (TwitterException e) {
                e.printStackTrace();
            }
        } else {

           Log.d("tW", "QUI");
        }
    }


    public void TwitterLogin(View v) {

        twinfo = (View) findViewById(R.id.twinfomail);
        RelativeLayout.LayoutParams layoutParams =
                (RelativeLayout.LayoutParams)twinfo.getLayoutParams();
        layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        twinfo.setLayoutParams(layoutParams);
        twinfo.setVisibility(View.INVISIBLE);

        dialog = new Dialog(this);
        dialog.hide();
        dialog.setContentView(R.layout.promptmail);
        dialog.setTitle("Twitter Request");

        Button dialogButton = (Button) dialog.findViewById(R.id.dialogButtonOK);
        dialogButton.setVisibility(View.VISIBLE);

        ImageButton why = (ImageButton) dialog.findViewById(R.id.whyBtn);
        // if button is clicked, close the custom dialog
        dialogButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
                EditText ed = (EditText) dialog.findViewById(R.id.editText);
                twmail = String.valueOf(ed.getText());
                if (twmail.contains("@")) {
                    loginToTwitter();
                    TwitterLogin = true;
                } else {
                    dialog.show();
                    Toast.makeText(LoginActivity.this, "Please, insert a valid e-mail to continue",Toast.LENGTH_SHORT).show();
                }

            }
        });

        why.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.hide();
                twinfo.setVisibility(View.VISIBLE);
                Button button = (Button) twinfo.findViewById(R.id.button);
                button.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        twinfo.setVisibility(View.INVISIBLE);
                        dialog.show();
                    }
                });
            }
        });

        dialog.show();

    }


    public void getData(User user) {

        Log.d("TW", "Inizio a caricare le informazioni dell'utente....");
        String temp = user.getName();
        String[] tem = new String[3];
        String delim = " ";

        /* given string will be split by the argument delimiter provided. */
        tem = temp.split(delim);
                  /* print substrings */

        /*
        twname = tem[0];
        Log.d("TW", twname);
        twsurname = tem[1];
        Log.d("TW", twsurname);
        */
        twname = temp;
        Log.d("TW", twname);
        twsurname = "";
        twurl = "http://twitter.com/"+user.getScreenName();
        twbio = user.getDescription();
        twpic = user.getOriginalProfileImageURL();
        twpost = user.getStatus().getText().toString();
        twid = Long.toString(user.getId());
        twsex = "U";
        twbday = "0000-00-00";

        loginid = twid;
        loginname = twname;
        loginsurname = twsurname;
        loginmail = twmail;
        loginpost = twpost;
        loginpic = twpic;
        loginurl = twurl;
        loginbio = twbio;
        loginbday = twbday;
        loginsex = twsex;

        Log.i("TwitterData", "valore ID twitter: " + twid);
        Log.i("TwitterData", "Nome Cognome: " + twname);
        Log.i("TwitterData", "Bio Twitter: " + twbio);
        Log.i("TwitterData", "URL Immagine Profilo: " + twpic);
        Log.i("TwitterData", "Ultimo Tweet: " + twpost);
        Log.i("TwitterData", "URL Sito Web Personale: " + twurl);

        new InsertAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertUtenti.php");
        new InsertMapAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertMappa.php");
        setLastAccount("twitter");

        Intent intent = new Intent(this, HomeActivity.class);
        startActivity(intent);
    }
    // Fine Implementazione Twitter Login


    // Inizio Implementazione GooglePlus Login
    public void GPlusLogin(View v) {
        GooglePlusLogin();
    }

    public void GooglePlusLogin() {

        mPlusClient.connect();

        if (mPlusClient.isConnected()) {
            mPlusClient.loadPeople(this, "me");
        } else {
            Toast.makeText(getApplicationContext(), "Please Sign In", Toast.LENGTH_SHORT).show();
            AccessoGPlus();
        }
    }

        public void AccessoGPlus() {

            if (!mPlusClient.isConnected()) {
                if (mConnectionResult == null) {
                    mConnectionProgressDialog.show();
                } else {
                    try {
                        mConnectionResult.startResolutionForResult(this, REQUEST_CODE_RESOLVE_ERR);
                    } catch (IntentSender.SendIntentException e) {
                        // Try connecting again.
                        mConnectionResult = null;
                        mPlusClient.connect();
                    }
                }
            }
        }


    @Override
    public void onConnectionFailed(ConnectionResult result) {
        if (mConnectionProgressDialog.isShowing() && mConnectionResult == null) {
            // The user clicked the sign-in button already. Start to resolve
            // connection errors. Wait until onConnected() to dismiss the
            // connection dialog.
            if (result.hasResolution()) {
                try {
                    result.startResolutionForResult(this, REQUEST_CODE_RESOLVE_ERR);
                } catch (IntentSender.SendIntentException e) {
                    mPlusClient.connect();
                }
            }
        }
        // Salva l'intent in modo che sia possibile avviare un'attività quando l'utente fa clic
        // sul pulsante di accesso.
        mConnectionResult = result;
    }

    @Override
    public void onConnected(Bundle connectionHint) {
        mConnectionProgressDialog.dismiss();

        String accountName = mPlusClient.getAccountName();
        Toast.makeText(this, accountName + " is connected.", Toast.LENGTH_SHORT).show();

        while (!mPlusClient.isConnected()) {
            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        mPlusClient.loadPeople(this, "me");
    }

    @Override
    public void onDisconnected() {
        Toast.makeText(this,  " Disconnected.", Toast.LENGTH_SHORT).show();
        Log.d("G+", "disconnected");
    }

    // Fine Implementazione GooglePlus Login


    public void setLastAccount(String account_name){
        SharedPreferences.Editor editor = sPrefs.edit();
        editor.putString("LAST_ACCOUNT", account_name);
        editor.commit();
    }

    @Override
    public void onPeopleLoaded(ConnectionResult status, PersonBuffer personBuffer,
                               String nextPageToken) {
        if (status.getErrorCode() == ConnectionResult.SUCCESS) {
            try {

                String temp = personBuffer.get(0).getDisplayName();
                String[] tem;
                String delim = " ";

                /* given string will be split by the argument delimiter provided. */
                tem = temp.split(delim);
                  /* print substrings */
                gname = tem[0];
                gsurname = tem[1];

                //gname = personBuffer.get(0).getDisplayName();
                gurl = personBuffer.get(0).getUrl();
                gid = personBuffer.get(0).getId();
                gpic = personBuffer.get(0).getImage().getUrl();
                gmail = mPlusClient.getAccountName();
                if (personBuffer.get(0).getBirthday() == null) {
                    gbday = "0000-00-00";
                } else {
                    gbday = personBuffer.get(0).getBirthday();
                }
                if (personBuffer.get(0).getGender() == 0) {
                    gsex = "M";
                } else if (personBuffer.get(0).getGender() == 1) {
                    gsex = "F";
                } else {
                    gsex = "U";
                }
                gbio = personBuffer.get(0).getAboutMe();
                gpost = "I love Google!!! <3";

            loginid = gid;
            loginname = gname;
            loginsurname = gsurname;
            loginmail = gmail;
            loginpost = gpost;
            loginpic = gpic;
            loginurl = gurl;
            loginbio = gbio;
            loginbday = gbday;
            loginsex = gsex;

            new InsertAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertUtenti.php");
            new InsertMapAsyncTask().execute("http://www.rambodrahmani.com/Ubi/android/insertMappa.php");
            setLastAccount("googleplus");

            Intent intent = new Intent(this, HomeActivity.class);
            startActivity(intent);

            } finally {
                personBuffer.close();
            }
        } else {
            Log.e("THIS", "Error listing people: " + status.getErrorCode());
        }

    }


    public class InsertAsyncTask extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... urls) {

            return INSERT(urls[0]);
        }
    }


    public String INSERT(String url) {
        if (loginname != "") {
            name = loginname;
            surname = loginsurname;
            mail = loginmail;
            lastpost = loginpost;
            picture = loginpic;
            page = loginurl;
            bio = loginbio;
            bday = loginbday;
            sex = loginsex;

            ArrayList<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
            nameValuePairs.add(new BasicNameValuePair("Nome", name));
            nameValuePairs.add(new BasicNameValuePair("Cognome", surname));
            nameValuePairs.add(new BasicNameValuePair("Email", mail));
            nameValuePairs.add(new BasicNameValuePair("LastPost", lastpost));
            nameValuePairs.add(new BasicNameValuePair("ProfilePic", picture));
            nameValuePairs.add(new BasicNameValuePair("ProfileURL", page));
            nameValuePairs.add(new BasicNameValuePair("Bio", bio));
            nameValuePairs.add(new BasicNameValuePair("DataNascita", bday));
            nameValuePairs.add(new BasicNameValuePair("Sesso", sex));

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
                Log.d("PROVAAAAAA", json_data.toString());
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


    public class InsertMapAsyncTask extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... urls) {

            return INSERTMAP(urls[0]);
        }
    }


    public String INSERTMAP(String url) {
        if (loginname != "") {
            mail = loginmail;
            picture = loginpic;

            ArrayList<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
            nameValuePairs.add(new BasicNameValuePair("Email", mail));
            nameValuePairs.add(new BasicNameValuePair("ProfilePic", picture));

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
                Log.e("InsertMappa - pass 2", "connection success ");
            } catch (Exception e) {
                Log.e("InsertMappa - Fail 2", e.toString());
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
                Log.e("InsertMappa - Fail 3", e.toString());
            }
        }
        return "Okay";

    }

    public void getTime() {
        SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy", Locale.ITALY);
        SimpleDateFormat format1 = new SimpleDateFormat("hh:mm:ss a", Locale.ITALY);
        date = format.format(new Date());
        time = format1.format(new Date());
        dateandtime = date+" "+time;
        Log.d("TIME", dateandtime);
    }


    public boolean isOnline() {
        ConnectivityManager cm =
                (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo netInfo = cm.getActiveNetworkInfo();
        if (netInfo != null && netInfo.isConnectedOrConnecting()) {
            return true;
        }
        return false;
    }


    @Override
    public void onPause() {
        super.onPause();
        //uiHelper.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        //uiHelper.onDestroy();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        //uiHelper.onSaveInstanceState(outState);
    }

    @Override
    protected void onStart() {
        super.onStart();

    }


    @Override
    public void onResume() {
        super.onResume();
        //uiHelper.onResume();
    }

    @Override
    protected void onStop() {
        super.onStop();
        // mPlusClient.disconnect();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == Activity.RESULT_OK && TwitterLogin) {
            String verifier = data.getExtras().getString(oAuthVerifier);
            try {
                AccessToken accessToken = twitter.getOAuthAccessToken(requestToken, verifier);

                long userID = accessToken.getUserId();
                final User user = twitter.showUser(userID);
                getData(user);

                saveTwitterInfo(accessToken);

            } catch (Exception e) {
                Log.e("Twitter Login Failed", e.getMessage());
            }
        }

        if (requestCode == REQUEST_CODE_RESOLVE_ERR && resultCode == RESULT_OK) {
            mConnectionResult = null;
            mPlusClient.connect();
        }

        if (FacebookLogIn) {
            Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
            AccessoFacebook();

        }
    }


}
