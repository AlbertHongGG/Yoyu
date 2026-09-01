package com.jasonhong.yoyu.yoyu

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.net.URL
import kotlin.math.roundToInt

class YoyuWidgetFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private var cardItems: List<JSONObject> = emptyList()

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonString = widgetData.getString("widget_cards_data", "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(jsonString)
            val list = mutableListOf<JSONObject>()
            for (i in 0 until jsonArray.length()) {
                list.add(jsonArray.getJSONObject(i))
            }
            cardItems = list
        } catch (e: Exception) {
            cardItems = emptyList()
        }
    }

    override fun onDestroy() {
        cardItems = emptyList()
    }

    override fun getCount(): Int = cardItems.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position >= cardItems.size) return null

        val item = cardItems[position]
        val views = RemoteViews(context.packageName, R.layout.widget_card_item)

        views.setTextViewText(R.id.card_name, item.optString("cardName", "我的卡片"))
        views.setTextViewText(R.id.card_no, item.optString("cardNo", ""))
        
        val balance = item.optDouble("lastTranSum", 0.0).roundToInt()
        views.setTextViewText(R.id.card_balance, "\$${balance}")

        val imgUrl = item.optString("cardFaceUrl", "")
        if (imgUrl.isNotEmpty()) {
            try {
                // Warning: loading network image synchronously on binder thread
                // StackView factory runs on background thread so it is allowed, 
                // but we should set timeout to avoid blocking.
                val url = URL(imgUrl)
                val connection = url.openConnection()
                connection.connectTimeout = 3000
                connection.readTimeout = 3000
                val inputStream = connection.getInputStream()
                val bitmap = BitmapFactory.decodeStream(inputStream)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.card_image, bitmap)
                }
            } catch (e: Exception) {
                // load fallback or ignore
            }
        }

        // Fill intent for on click if needed
        val fillInIntent = Intent()
        views.setOnClickFillInIntent(R.id.card_image, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
