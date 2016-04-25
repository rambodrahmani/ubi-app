package com.alwaysdreambig.ubi;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

/**
 * Created by andreamontanari on 28/09/14.
 */
public class TwInfoMail extends RelativeLayout {

    public TwInfoMail(Context context) {
        super(context);
        init();
    }

    public TwInfoMail(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TwInfoMail(Context context, AttributeSet attrs, int defStyle) {
        this(context, attrs);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.twinfomail, this);
    }
}

