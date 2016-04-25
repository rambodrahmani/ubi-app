package com.alwaysdreambig.ubi;

/**
 * Created by andreamontanari on 24/08/14.
 */
import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

public class CustomView extends RelativeLayout {

    public CustomView(Context context) {
        super(context);
        init();
    }

    public CustomView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CustomView(Context context, AttributeSet attrs, int defStyle) {
        this(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.custom, this);
    }
}
