package com.jasonhong.yoyu.yoyu

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class YoyuWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, YoyuWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setRemoteAdapter(R.id.widget_stack_view, intent)
                setEmptyView(R.id.widget_stack_view, R.id.widget_empty_view)
            }

            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_stack_view)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
