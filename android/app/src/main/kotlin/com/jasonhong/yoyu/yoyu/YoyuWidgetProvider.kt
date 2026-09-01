package com.jasonhong.yoyu.yoyu

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.net.URL
import kotlin.math.roundToInt
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class YoyuWidgetProvider : HomeWidgetProvider() {

    companion object {
        const val ACTION_NEXT = "com.jasonhong.yoyu.yoyu.ACTION_NEXT"
        const val ACTION_PREV = "com.jasonhong.yoyu.yoyu.ACTION_PREV"
        private const val PREFS_NAME = "YoyuWidgetPrefs"
        private const val KEY_CURRENT_INDEX = "current_card_index"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_NEXT || intent.action == ACTION_PREV) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, YoyuWidgetProvider::class.java))
            
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            var currentIndex = prefs.getInt(KEY_CURRENT_INDEX, 0)
            
            val jsonString = HomeWidgetPlugin.getData(context).getString("widget_cards_data", "[]") ?: "[]"
            val jsonArray = try { JSONArray(jsonString) } catch (e: Exception) { JSONArray() }
            
            if (jsonArray.length() > 0) {
                if (intent.action == ACTION_NEXT) {
                    currentIndex = (currentIndex + 1) % jsonArray.length()
                } else if (intent.action == ACTION_PREV) {
                    currentIndex = if (currentIndex - 1 < 0) jsonArray.length() - 1 else currentIndex - 1
                }
                prefs.edit().putInt(KEY_CURRENT_INDEX, currentIndex).apply()
                
                for (appWidgetId in appWidgetIds) {
                    updateWidget(context, appWidgetManager, appWidgetId)
                }
            }
        }
    }

    private fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonString = widgetData.getString("widget_cards_data", "[]") ?: "[]"
        val jsonArray = try { JSONArray(jsonString) } catch (e: Exception) { JSONArray() }
        
        if (jsonArray.length() == 0) {
            views.setViewVisibility(R.id.widget_empty_view, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.card_image, android.view.View.GONE)
            views.setViewVisibility(R.id.card_gradient, android.view.View.GONE)
            views.setViewVisibility(R.id.card_info_container, android.view.View.GONE)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            return
        }

        views.setViewVisibility(R.id.widget_empty_view, android.view.View.GONE)
        views.setViewVisibility(R.id.card_image, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.card_gradient, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.card_info_container, android.view.View.VISIBLE)

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        var currentIndex = prefs.getInt(KEY_CURRENT_INDEX, 0)
        if (currentIndex >= jsonArray.length()) {
            currentIndex = 0
            prefs.edit().putInt(KEY_CURRENT_INDEX, currentIndex).apply()
        }
        
        val item = jsonArray.getJSONObject(currentIndex)
        views.setTextViewText(R.id.card_name, item.optString("cardName", "我的卡片"))
        views.setTextViewText(R.id.card_no, item.optString("cardNo", ""))
        val balance = item.optDouble("lastTranSum", 0.0).roundToInt()
        views.setTextViewText(R.id.card_balance, "\$${balance}")

        // Setup click intents for pagination
        val nextIntent = Intent(context, YoyuWidgetProvider::class.java).apply { action = ACTION_NEXT }
        val nextPendingIntent = PendingIntent.getBroadcast(context, 0, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        views.setOnClickPendingIntent(R.id.btn_next, nextPendingIntent)

        val prevIntent = Intent(context, YoyuWidgetProvider::class.java).apply { action = ACTION_PREV }
        val prevPendingIntent = PendingIntent.getBroadcast(context, 1, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        views.setOnClickPendingIntent(R.id.btn_prev, prevPendingIntent)

        // Load image and update asynchronously
        val imgUrl = item.optString("cardFaceUrl", "")
        if (imgUrl.isNotEmpty()) {
            CoroutineScope(Dispatchers.IO).launch {
                val bitmap = loadAndRoundBitmap(context, imgUrl)
                if (bitmap != null) {
                    withContext(Dispatchers.Main) {
                        views.setImageViewBitmap(R.id.card_image, bitmap)
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }
                }
            }
        } else {
            // Apply a default dark rounded background if no image
            val defaultBitmap = createRoundedSolidBitmap(context, Color.parseColor("#2E2E2E"))
            views.setImageViewBitmap(R.id.card_image, defaultBitmap)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        // Initial update with text before image loads
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun loadAndRoundBitmap(context: Context, urlString: String): Bitmap? {
        return try {
            val url = URL(urlString)
            val connection = url.openConnection()
            connection.connectTimeout = 5000
            connection.readTimeout = 5000
            val inputStream = connection.getInputStream()
            val sourceBitmap = BitmapFactory.decodeStream(inputStream) ?: return null
            
            getRoundedCornerBitmap(context, sourceBitmap)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun createRoundedSolidBitmap(context: Context, color: Int): Bitmap {
        val width = 800
        val height = 400
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color }
        val radius = dpToPx(context, 16f)
        canvas.drawRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()), radius, radius, paint)
        return bitmap
    }

    private fun getRoundedCornerBitmap(context: Context, bitmap: Bitmap): Bitmap {
        val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val rect = Rect(0, 0, bitmap.width, bitmap.height)
        val rectF = RectF(rect)
        
        // Convert 16dp to pixels for rounded corners
        val roundPx = dpToPx(context, 16f)
        
        paint.color = Color.BLACK
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint)
        
        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(bitmap, rect, rect, paint)
        
        return output
    }
    
    private fun dpToPx(context: Context, dp: Float): Float {
        return dp * context.resources.displayMetrics.density
    }
}
