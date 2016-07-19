package com.alwaysdreambig.ubi;


import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

/**
 * Created by andreamontanari on 07/05/14.
 */

public class BarActivity extends Activity {

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
