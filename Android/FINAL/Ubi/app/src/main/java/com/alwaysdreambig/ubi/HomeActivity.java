package com.alwaysdreambig.ubi;

import android.app.ActionBar;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TabHost;
import android.widget.TextView;

public class HomeActivity extends TabActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        setcontrol();

        final TabHost tabHost = getTabHost();

        TabHost.TabSpec mapspec = tabHost.newTabSpec("Map");
        mapspec.setIndicator("", getResources().getDrawable(R.drawable.icons_map));
        Intent mapIntent = new Intent(this, MapActivity.class);
        mapspec.setContent(mapIntent);

        TabHost.TabSpec timelinespec = tabHost.newTabSpec("Timeline");
        timelinespec.setIndicator("", getResources().getDrawable(R.drawable.icons_timeline));
        Intent timelineIntent = new Intent(this, TimelineActivity.class);
        timelinespec.setContent(timelineIntent);

        TabHost.TabSpec messagesspec = tabHost.newTabSpec("Messages");
        messagesspec.setIndicator("", getResources().getDrawable(R.drawable.icons_messages));
        Intent messagesIntent = new Intent(this, MessagesActivity.class);
        messagesspec.setContent(messagesIntent);

        TabHost.TabSpec settingsspec = tabHost.newTabSpec("Settings");
        settingsspec.setIndicator("", getResources().getDrawable(R.drawable.icons_settings));
        Intent settingsIntent = new Intent(this, SettingsActivity.class);
        settingsspec.setContent(settingsIntent);

        tabHost.addTab(mapspec);
        tabHost.addTab(timelinespec);
        tabHost.addTab(messagesspec);
        tabHost.addTab(settingsspec);

        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x/4;
        int height = width;

        for (int i = 0; i < tabHost.getTabWidget().getTabCount(); i++) {
            tabHost.getTabWidget().getChildAt(i).setLayoutParams(new LinearLayout.LayoutParams(width,height-72));
            tabHost.getTabWidget().getChildAt(i).setBackgroundDrawable(null);
            tabHost.getTabWidget().getChildAt(i).setPadding(0, 0, 0, 0);
        }
        tabHost.getTabWidget().setStripEnabled(false);
        tabHost.getTabWidget().getChildAt(0).setBackgroundColor(0xff1a1c21);

        tabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            @Override
            public void onTabChanged(String tabId) {
                for (int i = 0; i < tabHost.getTabWidget().getTabCount(); i++) {
                    tabHost.getTabWidget().getChildAt(i).setBackgroundColor(0xff23252a);
                }
                int i = tabHost.getCurrentTab();
                tabHost.getTabWidget().getChildAt(i).setBackgroundColor(0xff1a1c21);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    public void setcontrol() {
        ActionBar actionBar = getActionBar();
        LayoutInflater inflater = (LayoutInflater) this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = inflater.inflate(R.layout.actionbar, null);
        Typeface font = Typeface.createFromAsset(getAssets(), "fonts/Billabong.ttf");
        TextView title = ((TextView)view.findViewById(R.id.custom_bar));
        title.setTypeface(font);

        actionBar.setCustomView(view, new ActionBar.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        actionBar.setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        actionBar.setDisplayShowCustomEnabled(true);
        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setDisplayUseLogoEnabled(false);
    }
}

