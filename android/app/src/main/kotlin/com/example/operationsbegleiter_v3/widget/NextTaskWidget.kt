package com.example.operationsbegleiter_v3.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.operationsbegleiter_v3.R
import es.antonborri.home_widget.HomeWidgetProvider

class NextTaskWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_next_task)

            val title = widgetData.getString("nextTaskTitle", "") ?: ""
            val taskType = widgetData.getString("nextTaskType", "") ?: ""
            val time = widgetData.getString("nextTaskTime", "") ?: ""
            val openCount = widgetData.getInt("openTaskCount", 0)

            if (title.isEmpty()) {
                views.setTextViewText(R.id.task_title, "Alles erledigt! ✓")
                views.setTextViewText(R.id.task_time, "")
            } else {
                views.setTextViewText(R.id.task_title, title)
                views.setTextViewText(R.id.task_time, time)
            }

            val iconRes = when (taskType) {
                "wound" -> R.drawable.ic_widget_wound
                "meds" -> R.drawable.ic_widget_meds
                "checklist" -> R.drawable.ic_widget_checklist
                "appointment" -> R.drawable.ic_widget_calendar
                "nutrition" -> R.drawable.ic_widget_nutrition
                else -> R.drawable.ic_widget_task
            }
            views.setImageViewResource(R.id.task_icon, iconRes)

            if (openCount > 0) {
                views.setTextViewText(R.id.task_count, "$openCount offene Tasks")
            } else {
                views.setTextViewText(R.id.task_count, "")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
