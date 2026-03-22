package com.example.operationsbegleiter_v3.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.operationsbegleiter_v3.R
import es.antonborri.home_widget.HomeWidgetProvider

class StreakWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_streak)

            val currentStreak = widgetData.getInt("currentStreak", 0)
            val longestStreak = widgetData.getInt("longestStreak", 0)

            views.setTextViewText(R.id.streak_count, "$currentStreak")
            views.setTextViewText(
                R.id.streak_label,
                if (currentStreak == 1) "Tag" else "Tage"
            )
            views.setTextViewText(R.id.streak_record, "Rekord: $longestStreak")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
