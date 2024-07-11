package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.util.SizeF
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import android.content.Intent
import android.app.PendingIntent
import android.content.ComponentName
import android.os.Bundle
import android.util.Log
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.ListSharedPrefsUtil
import ca.etsmtl.applets.etsmobile.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SemesterProgressWidgetSmall : AppWidgetProvider() {
    companion object {
        private var semesterProgress: SemesterProgress? = null

        @RequiresApi(Build.VERSION_CODES.O)
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            getProgressInfo(context)

            val views = RemoteViews(context.packageName, R.layout.widget_semester_progress_small)

            views.apply {
                // Get theme values
                val (backgroundColor, textColor) = ListSharedPrefsUtil.getSemesterProgressWidgetTheme(
                    context,
                    appWidgetId
                )
                setInt(R.id.widget_background, "setColorFilter", backgroundColor)

                // Set the progression for both small and large widget sizes
                semesterProgress?.completedPercentageAsInt?.let {
                    setProgressBar(R.id.progressBar, 100,
                        it, false)
                }
                // Set the progress percentage text for the small widget
                setTextViewText(R.id.progress_text, "${semesterProgress?.completedPercentageAsInt} %")
                setTextViewText(R.id.elapsed_days_text, "${semesterProgress?.elapsedDays} / ${semesterProgress?.totalDays}")
            }

            views.let {
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun getProgressInfo(context: Context){
            if (semesterProgress == null || semesterProgress?.isPastEndDate() == true) {
                CoroutineScope(Dispatchers.IO).launch {
                    // TODO add timeout if nulls are returned
                    // TODO add error handling
                    Log.d("SemesterProgressWidget", "Fetching semester progress")
                    semesterProgress = SemesterProgressWidgetUtils.getSemesterProgress()
                }
            } else if (semesterProgress?.isOngoing() == true) {
                Log.d("SemesterProgressWidget", "Calculating progress")
                semesterProgress?.calculateProgress()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getProgressInfo(context)

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateAllAppWidgets(context)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun updateAllAppWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, SemesterProgressWidgetSmall::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}