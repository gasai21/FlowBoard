package com.example.flowboard

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.example.flowboard.R

class TaskWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                setTextViewText(R.id.widget_workspace_name, widgetData.getString("workspace_name", "FlowBoard"))

                // Board 1
                val b1Title = widgetData.getString("board_1_title", "")
                if (b1Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_board_1_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_board_1_container, View.VISIBLE)
                    setTextViewText(R.id.widget_board_1_title, b1Title)
                    setTextViewText(R.id.widget_board_1_tasks, widgetData.getString("board_1_tasks", "0 tasks"))
                }

                // Board 2
                val b2Title = widgetData.getString("board_2_title", "")
                if (b2Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_board_2_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_board_2_container, View.VISIBLE)
                    setTextViewText(R.id.widget_board_2_title, b2Title)
                    setTextViewText(R.id.widget_board_2_tasks, widgetData.getString("board_2_tasks", "0 tasks"))
                }

                // Board 3
                val b3Title = widgetData.getString("board_3_title", "")
                if (b3Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_board_3_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_board_3_container, View.VISIBLE)
                    setTextViewText(R.id.widget_board_3_title, b3Title)
                    setTextViewText(R.id.widget_board_3_tasks, widgetData.getString("board_3_tasks", "0 tasks"))
                }

                // Board 4
                val b4Title = widgetData.getString("board_4_title", "")
                if (b4Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_board_4_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_board_4_container, View.VISIBLE)
                    setTextViewText(R.id.widget_board_4_title, b4Title)
                    setTextViewText(R.id.widget_board_4_tasks, widgetData.getString("board_4_tasks", "0 tasks"))
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
