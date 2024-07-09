package ca.etsmtl.applets.etsmobile

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
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser

class ProgressWidget : AppWidgetProvider() {
    companion object {
        const val WIDGET_BUTTON_CLICK = "ca.etsmtl.applets.etsmobile.WIDGET_BUTTON_CLICK"
        const val CHANNEL = "widget_method_channel"

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

        var progresses = arrayOf<String>()
        var currentProgressIndex = 1

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            // Handle clicks on the widget
            val intent = Intent(context, ProgressWidget::class.java)
            intent.action = WIDGET_BUTTON_CLICK
            val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)

            val semesterProgressLarge = RemoteViews(context.packageName, R.layout.widget_semester_progress_large)
            val semesterProgressSmall = RemoteViews(context.packageName, R.layout.widget_semester_progress_small)

            val widgetSize = getWidgetSize(appWidgetManager, appWidgetId)
            val views = if (widgetSize.width <= 140) {
                semesterProgressSmall
            } else {
                semesterProgressLarge
            }

            views.apply {
                // Get theme values
                val (backgroundColor, textColor) = ListSharedPrefsUtil.getSemesterProgressWidgetTheme(context, appWidgetId)
                setInt(R.id.widget_background, "setColorFilter", backgroundColor)

                // Set the progression for both small and large widget sizes
                setProgressBar(R.id.progressBar, 100, progress, false)

                // Set the progress percentage text for the small widget
                setTextViewText(R.id.progress_text, "$progress %")
                setTextViewText(R.id.elapsed_days_text, getElapsedDaysOverTotal(false))

                // Set the title and progress text for the large widget size
                setTextViewText(R.id.semester_progress_title, title)
                setTextColor(R.id.semester_progress_title, textColor)
                setTextViewText(R.id.progressText, progresses[currentProgressIndex])

                setOnClickPendingIntent(R.id.semester_progress_widget, pendingIntent)
            }

            views.let {
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }

        @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
        private fun getWidgetSize(appWidgetManager: AppWidgetManager, appWidgetId: Int): SizeF {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            return SizeF(minWidth.toFloat(), minHeight.toFloat())
        }

        private fun getRemainingDays(): String {
            val remainingDays = totalDays - elapsedDays
            val remainingText = if (suffix == "jours") "restant" else "remaining"
            return "$remainingDays $suffix $remainingText"
        }

        private fun getElapsedDaysOverTotal(addSuffix: Boolean): String {
            if (!addSuffix) {
                return "$elapsedDays / $totalDays"
            }

            val elapsedText = if (suffix == "jours") "écoulés" else "elapsed"
            return "$elapsedDays $elapsedText / $totalDays $suffix"
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getProgressInfo(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (WIDGET_BUTTON_CLICK == intent.action) {
            // Go to the next progress text
            currentProgressIndex = (currentProgressIndex + 1) % progresses.size
            updateAllAppWidgets(context)
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateAllAppWidgets(context)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun updateAllAppWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, ProgressWidget::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun getProgressInfo(context: Context){
//        val widgetData = HomeWidgetPlugin.getData(context)

//        title = widgetData.getString(TITLE_KEY, "Semester Progress") ?: "Semester Progress"
//        progress = widgetData.getInt(PROGRESS_KEY, 0)
//        elapsedDays = widgetData.getInt(ELAPSED_DAYS_KEY, 0)
//        totalDays = widgetData.getInt(TOTAL_DAYS_KEY, 0)
//        suffix = widgetData.getString(SUFFIX_KEY, "days") ?: "days"

        title = "Semester Progress"
        progress = 0
        elapsedDays = 0
        totalDays = 0
        suffix = "days"

        progresses = arrayOf("$progress %", getElapsedDaysOverTotal(true), getRemainingDays())
    }
}