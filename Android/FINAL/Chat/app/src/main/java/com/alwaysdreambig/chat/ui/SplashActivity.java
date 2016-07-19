package com.alwaysdreambig.chat.ui;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;

import com.alwaysdreambig.chat.ApplicationSingleton;
import com.alwaysdreambig.chat.R;
import com.quickblox.chat.QBGroupChat;
import com.quickblox.chat.QBGroupChatManager;
import com.quickblox.chat.QBPrivateChat;
import com.quickblox.chat.QBPrivateChatManager;
import com.quickblox.chat.listeners.QBIsTypingListener;
import com.quickblox.chat.listeners.QBMessageListener;
import com.quickblox.chat.listeners.QBPrivateChatManagerListener;
import com.quickblox.core.QBEntityCallbackImpl;
import com.quickblox.core.QBSettings;
import com.quickblox.auth.QBAuth;
import com.quickblox.auth.model.QBSession;
import com.quickblox.chat.QBChatService;
import com.quickblox.users.QBUsers;
import com.quickblox.users.model.QBUser;

import java.util.List;

public class SplashActivity extends Activity {

    public static final String TAG ="PROVA";

    //saving tools
    private SharedPreferences sPrefs;
    public static String PREF_USER = "user";

    //additional info
    public static String ServerApiDomain = "api.quickblox.com";
    public static String ServerChatDomain = "chat.quickblox.com";
    public static String ContentBucket = "qbprod";

    /*PROVA Con Rambod
    static final String APP_ID = "15143";
    static final String AUTH_KEY = "pPmxurA2R9qF5aw";
    static final String AUTH_SECRET ="OcmZQxjyHShcYqH";

    static String USER_NAME = "Andrea Montanari";
    static String USER_LOGIN = "montanariandrea25@yahoo.it";
    static String USER_PWD = "password";
    static int USER_ID;
    */
    //prova MIA
    static final String APP_ID = "15049";
    static final String AUTH_KEY = "XQXQL-42HdbrG7b";
    static final String AUTH_SECRET ="xaGyRFMwTwHcLzf";

    static String USER_NAME = "Paolo Bianchi";
    static String USER_LOGIN = "paolobianchi@yahoo.it";
    static String USER_PWD = "password";
    static int USER_ID;

    //test
    private QBChatService chatService;

    // 1-1 Chat
    //
    private QBPrivateChatManager privateChatManager;
    private QBMessageListener<QBPrivateChat> privateChatMessageListener;
    private QBIsTypingListener<QBPrivateChat> privateChatIsTypingListener;
    private QBPrivateChatManagerListener privateChatManagerListener;

    // Group Chat
    //
    public static QBGroupChatManager groupChatManager;
    private QBMessageListener<QBGroupChat> groupChatQBMessageListener;
    private QBGroupChat currentChatRoom;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        QBSettings.getInstance().fastConfigInit(APP_ID, AUTH_KEY, AUTH_SECRET);

        QBChatService.setDebugEnabled(true);

        if (!QBChatService.isInitialized()) {
            QBChatService.init(this);
        }
        chatService = QBChatService.getInstance();
        Log.d(TAG, "inizializzata chatservice");

        //create application session
        QBAuth.createSession(new QBEntityCallbackImpl<QBSession>() {

            @Override
            public void onSuccess(QBSession session, Bundle params) {
                super.onSuccess(session, params);
                Log.i(TAG, "session created, token = " + session.getToken());

                final QBUser user = new QBUser();
                user.setLogin(USER_LOGIN);
                user.setPassword(USER_PWD);
                user.setFullName(USER_NAME);
                //save current user
                user.setId(session.getUserId());
                ((ApplicationSingleton)getApplication()).setCurrentUser(user);

                login(user);
            }

            @Override
            public void onError(List<String> errors) {
                Log.d(TAG, "session errors: " + errors);
            }
        });
    }

    //login
    public void login(final QBUser user) {

        QBUsers.signIn(user, new QBEntityCallbackImpl<QBUser>() {

            @Override
            public void onSuccess(QBUser user, Bundle params) {
                Log.i(TAG, ">>> User was successfully signed in:  " + user.toString());
                USER_ID = getUserID();
                loginToChat();
            }

            @Override
            public void onError(List<String> errors) {
                register();
                Log.d(TAG, "error when login: " + errors);
            }
        });
    }

     //sign up --> sign in
    public void register() {

        QBAuth.createSession(new QBEntityCallbackImpl<QBSession>() {

            @Override
            public void onSuccess(QBSession session, Bundle params) {
                super.onSuccess(session, params);
                Log.i(TAG, "session created, token = " + session.getToken());

                final QBUser user = new QBUser();
                user.setLogin(USER_LOGIN);
                user.setPassword(USER_PWD);
                user.setFullName(USER_NAME);
                //save current user
                user.setId(session.getUserId());
                ((ApplicationSingleton)getApplication()).setCurrentUser(user);


                QBUsers.signUpSignInTask(user, new QBEntityCallbackImpl<QBUser>() {
                    @Override
                    public void onSuccess(QBUser user, Bundle args) {
                        Log.i(TAG, ">>> User was successfully signed up and signed in, " + user);

                        USER_ID = user.getId();
                        Log.d("PROVA", "lo user id prima del salvataggio è: "+USER_ID);
                        saveUser();
                        Log.d("PROVA", "dopo il salvataggio userid è: "+USER_ID);

                        loginToChat();
                    }

                    @Override
                    public void onError(List<String> errors) {
                        super.onError(errors);
                    }
                });
            }

            @Override
            public void onError(List<String> errors) {
                Log.d(TAG, "error when login: " + errors);
            }
        });

    }
    //login to chat
    public void loginToChat() {
        QBUser qbUser = new QBUser();
        qbUser.setId(USER_ID);
        qbUser.setPassword(USER_PWD);

        chatService.login(qbUser, new QBEntityCallbackImpl() {
            @Override
            public void onSuccess() {

                Log.d(TAG, "success when login");

                initChatPrivateAndGroupManagers();

                Intent intent = new Intent(SplashActivity.this, DialogsActivity.class);
                startActivity(intent);
            }

            @Override
            public void onError(List errors) {
                Log.d(TAG, "error when login to chat: " + errors);
            }
        });
    }

    private void initChatPrivateAndGroupManagers(){
        // Get 1-1 chat manager
        //
        privateChatManager = chatService.getPrivateChatManager();

        // Create 1-1 chat manager listener
        //
        privateChatManagerListener = new QBPrivateChatManagerListener() {
            @Override
            public void chatCreated(final QBPrivateChat privateChat, final boolean createdLocally) {
                if(!createdLocally){
                    Log.i(TAG, "adding message listener to new chat");
                    privateChat.addMessageListener(privateChatMessageListener);
                    privateChat.addIsTypingListener(privateChatIsTypingListener);
                }

                Log.d(TAG, "chatCreated: " + privateChat + ", createdLocally: " + createdLocally);
            }
        };
        //
        privateChatManager.addPrivateChatManagerListener(privateChatManagerListener);


        // Get group chat manager
        //
        groupChatManager = chatService.getGroupChatManager();
    }

    public void saveUser() {
        SharedPreferences.Editor editor = getSharedPreferences(PREF_USER, MODE_PRIVATE).edit();
        editor.putInt("USER_ID", USER_ID);
        Log.d("SALVATAGGIO", "userid: "+USER_ID);
        editor.putString("USER_LOGIN", USER_LOGIN);
        Log.d("SALVATAGGIO", "userli: "+USER_LOGIN);
        editor.putString("USER_PWD", USER_PWD);
        Log.d("SALVATAGGIO", "userpwd: "+USER_PWD);
        editor.commit();

    }

    public int getUserID() {

        SharedPreferences prefs = getSharedPreferences(PREF_USER, MODE_PRIVATE);
        int userid = prefs.getInt("USER_ID",0);
        if (userid != 0) {
            return userid;
        } else {
            return 0;
        }
    }

    public String getUserPWD() {
        SharedPreferences prefs = getSharedPreferences(PREF_USER, MODE_PRIVATE);
        String userwd = prefs.getString("USER_PWD", null);
        if (userwd != null) {
            return userwd;
        } else {
            return null;
        }
    }

    public String getUserName() {
        SharedPreferences prefs = getSharedPreferences(PREF_USER, MODE_PRIVATE);
        String username = prefs.getString("USER_Name", null);
        if (username != null) {
            return username;
        } else {
            return null;
        }
    }

}