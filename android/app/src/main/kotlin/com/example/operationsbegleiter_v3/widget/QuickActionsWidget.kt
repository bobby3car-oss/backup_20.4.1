package com.example.operationsbegleiter_v3.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.operationsbegleiter_v3.R
import es.antonborri.home_widget.HomeWidgetProvider

class QuickActionsWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_actions)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
