package ca.etsmtl.applets.etsmobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.SizeF
import kotlinx.android.synthetic.main.widget_semester_progress_small.*

class ProgressWidgetProvider : AppWidgetProvider() {
    private val ACTION_WIDGET_CLICK = "ca.etsmtl.applets.etsmobile.WIDGET_CLICK"

    companion object {
        private const val PREFIX_KEY = "progress_"
        const val PROGRESS_KEY = PREFIX_KEY + "progressInt"
        const val ELAPSED_DAYS_KEY = PREFIX_KEY + "elapsedDays"
        const val TOTAL_DAYS_KEY = PREFIX_KEY + "totalDays"
        const val SUFFIX_KEY = PREFIX_KEY + "suffix"
        const val TITLE_KEY = PREFIX_KEY + "title"

        var progress = 0
        var elapsedDays = 0
        var totalDays = 0
        var suffix = "days"
        var title = "Semester Progress"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getProgressInfo(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val semesterProgressLarge = RemoteViews(context.packageName, R.layout.widget_semester_progress_large)
        val semesterProgressSmall = RemoteViews(context.packageName, R.layout.widget_semester_progress_small)

        val viewMapping: Map<SizeF, RemoteViews> = mapOf(
            SizeF(320f, 40f) to semesterProgressLarge, // 5x1
            SizeF(250f, 40f) to semesterProgressLarge, // 4x1
            SizeF(110f, 40f) to semesterProgressSmall // 2x1
        )

        semesterProgressSmall.setTextViewText(R.id.progress_text, "$progress %" ?: "0")
        semesterProgressSmall.setTextViewText(R.id.elapsed_days_text, getElapsedDaysOverTotal() ?: "0")
        semesterProgressSmall.setProgressBar(R.id.progressBar, 100, progress, false)

        semesterProgressLarge.setTextViewText(R.id.semester_progress_title, title)
        semesterProgressLarge.setProgressBar(R.id.progressBar, 100, progress, false)
        semesterProgressLarge.setTextViewText(R.id.progressText, "$progress %" ?: "0")
        // views.setTextViewText(R.id.progressText, getRemainingDays() ?: "0")

        val views = RemoteViews(viewMapping)

        views.let {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun getProgressInfo(context: Context){
        val widgetData = HomeWidgetPlugin.getData(context)

        title = widgetData.getString(TITLE_KEY, "Semester Progress") ?: "Semester Progress"
        progress = widgetData.getInt(PROGRESS_KEY, 0)
        elapsedDays = widgetData.getInt(ELAPSED_DAYS_KEY, 0)
        totalDays = widgetData.getInt(TOTAL_DAYS_KEY, 0)
        suffix = widgetData.getString(SUFFIX_KEY, "days") ?: "days"
    }

    private fun getRemainingDays(): String {
        val remainingDays = totalDays - elapsedDays
        return "$remainingDays $suffix"
    }

    private fun getElapsedDaysOverTotal(): String {
        return "$elapsedDays / $totalDays"
    }
}