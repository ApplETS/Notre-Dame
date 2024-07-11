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

class SemesterProgressWidget : AppWidgetProvider() {
    companion object {
        const val WIDGET_BUTTON_CLICK = "ca.etsmtl.applets.etsmobile.WIDGET_BUTTON_CLICK"
        private const val MAX_PROGRESS_VARIANT_INDEX = 2
        private var semesterProgress: SemesterProgress? = null

        private var daysText = "days"
        private var title = "Semester Progress"

        @RequiresApi(Build.VERSION_CODES.O)
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            getProgressInfo(context)

            // Handle clicks on the widget
            val intent = Intent(context, SemesterProgressWidget::class.java).apply {
                action = WIDGET_BUTTON_CLICK
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val pendingIntent = PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT)

            val semesterProgressLarge = RemoteViews(context.packageName,
                R.layout.widget_semester_progress_large
            )
            val semesterProgressSmall = RemoteViews(context.packageName,
                R.layout.widget_semester_progress_small
            )

            val widgetSize = getWidgetSize(appWidgetManager, appWidgetId)
            val views = if (widgetSize.width <= 140) {
                semesterProgressSmall
            } else {
                semesterProgressLarge
            }

            val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
            val currentVariantIndex = sharedPreferences.getInt("current_variant_index_$appWidgetId", 0)
            val currentText = sharedPreferences.getString("progress_variant_$currentVariantIndex", "N/A")

            views.apply {
                // Get theme values
                val (backgroundColor, textColor) = ListSharedPrefsUtil.getSemesterProgressWidgetTheme(
                    context,
                    appWidgetId
                )
                setInt(R.id.widget_background, "setColorFilter", backgroundColor)

                // Set the progression for both small and large widget sizes
                semesterProgress?.completedPercentage?.let { setProgressBar(R.id.progressBar, 100, it.toInt(), false) }

                // Set the progress percentage text for the small widget
                setTextViewText(R.id.progress_text, "${semesterProgress?.completedPercentage} %")
                setTextViewText(R.id.elapsed_days_text, getElapsedDaysOverTotalText(false))

                // Set the title and progress text for the large widget size
                setTextViewText(R.id.semester_progress_title, title)
                setTextColor(R.id.semester_progress_title, textColor)
                setTextViewText(R.id.progressText, currentText)

                setOnClickPendingIntent(R.id.semester_progress_widget, pendingIntent)
            }

            views.let {
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }

        private fun getWidgetSize(appWidgetManager: AppWidgetManager, appWidgetId: Int): SizeF {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            return SizeF(minWidth.toFloat(), minHeight.toFloat())
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun cycleText(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
            val currentVariantIndex = sharedPreferences.getInt("current_variant_index_$appWidgetId", 0)
            val newVariantIndex = (currentVariantIndex + 1) % (MAX_PROGRESS_VARIANT_INDEX + 1)

            sharedPreferences.edit().putInt("current_variant_index_$appWidgetId", newVariantIndex).apply()
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun getRemainingDays(): String {
            val remainingText = if (daysText == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_REMAINING_FR else Constants.SEMESTER_PROGRESS_REMAINING_EN
            return "${semesterProgress?.remainingDays} $daysText $remainingText"
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun getElapsedDaysOverTotalText(addSuffix: Boolean): String {
            if (!addSuffix) {
                return "${semesterProgress?.elapsedDays} / ${semesterProgress?.totalDays}"
            }

            val elapsedText = if (daysText == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_ELAPSED_FR else Constants.SEMESTER_PROGRESS_ELAPSED_EN
            return "${semesterProgress?.elapsedDays} $daysText $elapsedText / ${semesterProgress?.totalDays} $daysText"
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun getProgressInfo(context: Context){
            if (semesterProgress == null || semesterProgress?.isPastEndDate() == true) {
                CoroutineScope(Dispatchers.IO).launch {
                    Log.d("SemesterProgressWidget", "Fetching semester progress")
                    semesterProgress = SemesterProgressWidgetUtils.getSemesterProgress()
                }
            } else if (semesterProgress?.isOngoing() == true) {
                Log.d("SemesterProgressWidget", "Calculating progress")
                semesterProgress?.calculateProgress()
            }

            context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", "${semesterProgress?.completedPercentage?.toInt()} %")
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_1", getElapsedDaysOverTotalText(true))
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_2", getRemainingDays())
                apply()
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
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, SemesterProgressWidget::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}