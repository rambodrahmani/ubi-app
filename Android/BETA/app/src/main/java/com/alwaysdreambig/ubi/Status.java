package com.alwaysdreambig.ubi;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

/**
 * Created by andreamontanari on 29/09/14.
 */
public class Status extends RelativeLayout {

    public Status(Context context) {
        super(context);
        init();
    }

    public Status(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public Status(Context context, AttributeSet attrs, int defStyle) {
        this(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.status, this);
    }
}