package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.R

class SemesterProgressWidgetLarge : SemesterProgressWidgetBase() {
    override val layoutId: Int
        get() = R.layout.widget_semester_progress_large

    override val setViews: (RemoteViews, Context, Int) -> Unit
        @RequiresApi(Build.VERSION_CODES.O)
        get() = { views, context, appWidgetId ->
            semesterProgress?.completedPercentageAsInt?.let {
                views.setProgressBar(R.id.progressBar, 100, it, false)
            }
            views.setTextViewText(R.id.progress_text, "${semesterProgress?.completedPercentageAsInt} %")
            views.setTextViewText(R.id.elapsed_days_text, getElapsedDaysOverTotalText(false))
            views.setTextViewText(R.id.semester_progress_title, "Semester Progress")
            views.setTextColor(R.id.semester_progress_title, context.getColor(R.color.white))
            views.setTextViewText(R.id.progressText, getCurrentText(context, appWidgetId))
            views.setOnClickPendingIntent(R.id.semester_progress_widget, getPendingIntent(context, appWidgetId))
        }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (WIDGET_BUTTON_CLICK == intent.action) {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                cycleText(context, AppWidgetManager.getInstance(context), appWidgetId)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun cycleText(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
        val currentVariantIndex = sharedPreferences.getInt("${Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY}_$appWidgetId", 0)
        val newVariantIndex = (currentVariantIndex + 1) % (MAX_PROGRESS_VARIANT_INDEX + 1)

        sharedPreferences.edit().putInt("${Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY}_$appWidgetId", newVariantIndex).apply()
        updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
    }
}