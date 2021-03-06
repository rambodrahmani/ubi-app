package com.alwaysdreambig.ubi;

/**
 * Created by andreamontanari on 24/08/14.
 */
import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

public class LoadingView extends RelativeLayout {

    public LoadingView(Context context) {
        super(context);
        init();
    }

    public LoadingView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public LoadingView(Context context, AttributeSet attrs, int defStyle) {
        this(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.loading, this);
    }
}
