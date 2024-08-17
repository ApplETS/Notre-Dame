package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.R

class SemesterProgressWidgetSmall : SemesterProgressWidgetBase() {
    override val layoutId: Int
        get() = R.layout.widget_semester_progress_small

    private fun getPercentageText(): String {
        return "${semesterProgress?.completedPercentageAsInt} %"
    }

    private fun getElapsedDaysText(): String {
        return "${semesterProgress?.elapsedDays} / ${semesterProgress?.totalDays}"
    }

    override val setViews: (RemoteViews, Context, Int) -> Unit
        get() = { views, context, appWidgetId ->
            semesterProgress?.completedPercentageAsInt?.let {
                views.setProgressBar(R.id.progressBar, 100,
                    it, false)
            }
            views.setTextViewText(R.id.progress_text, getPercentageText())
            views.setTextViewText(R.id.elapsed_days_text, getElapsedDaysText())
            views.setOnClickPendingIntent(R.id.semester_progress_widget, getPendingIntent(context, appWidgetId))
        }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (Constants.WIDGET_BUTTON_CLICK == intent.action) {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                getProgressInfo(context)
            }
        }
    }
}