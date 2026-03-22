package com.example.operationsbegleiter_v3.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.example.operationsbegleiter_v3.R
import es.antonborri.home_widget.HomeWidgetProvider

class DayOverviewWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_day_overview)

            val nextTask = widgetData.getString("nextTaskTitle", "") ?: ""
            val nextTaskTime = widgetData.getString("nextTaskTime", "") ?: ""
            val nextTaskType = widgetData.getString("nextTaskType", "") ?: ""
            val openCount = widgetData.getInt("openTaskCount", 0)
            val currentStreak = widgetData.getInt("currentStreak", 0)
            val lastPainLevel = widgetData.getInt("lastPainLevel", -1)
            val nextAptTitle = widgetData.getString("nextAppointmentTitle", "") ?: ""
            val nextAptTime = widgetData.getString("nextAppointmentTime", "") ?: ""

            // Appointment section
            if (nextAptTitle.isEmpty()) {
                views.setTextViewText(R.id.apt_title, "Kein Termin")
                views.setTextViewText(R.id.apt_time, "")
            } else {
                views.setTextViewText(R.id.apt_title, nextAptTitle)
                views.setTextViewText(R.id.apt_time, nextAptTime)
            }

            // Task section
            if (nextTask.isEmpty()) {
                views.setTextViewText(R.id.task_title, "Alles erledigt ✓")
                views.setTextViewText(R.id.task_subtitle, "")
            } else {
                views.setTextViewText(R.id.task_title, nextTask)
                views.setTextViewText(R.id.task_subtitle, "$openCount offen · $nextTaskTime")
            }

            val taskIconRes = when (nextTaskType) {
                "wound" -> R.drawable.ic_widget_wound
                "meds" -> R.drawable.ic_widget_meds
                "checklist" -> R.drawable.ic_widget_checklist
                "appointment" -> R.drawable.ic_widget_calendar
                "nutrition" -> R.drawable.ic_widget_nutrition
                else -> R.drawable.ic_widget_task
            }
            views.setImageViewResource(R.id.task_icon, taskIconRes)

            // Streak
            views.setTextViewText(R.id.streak_value, "🔥 $currentStreak")

            // Pain
            if (lastPainLevel >= 0) {
                views.setTextViewText(R.id.pain_value, "$lastPainLevel")
            } else {
                views.setTextViewText(R.id.pain_value, "–")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
