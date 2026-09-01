package com.jasonhong.yoyu.yoyu

import android.content.Intent
import android.widget.RemoteViewsService

class YoyuWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return YoyuWidgetFactory(this.applicationContext, intent)
    }
}
