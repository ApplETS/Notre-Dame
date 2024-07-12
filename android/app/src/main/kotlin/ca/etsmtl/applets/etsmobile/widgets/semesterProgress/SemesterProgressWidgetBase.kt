package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import android.content.Intent
import android.app.PendingIntent
import android.content.ComponentName
import android.os.Bundle
import android.util.Log
import ca.etsmtl.applets.etsmobile.Constants
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

abstract class SemesterProgressWidgetBase : AppWidgetProvider() {
    companion object {
        var semesterProgress: SemesterProgress? = null
        const val MAX_PROGRESS_VARIANT_INDEX = 2
        const val WIDGET_BUTTON_CLICK = "ca.etsmtl.applets.etsmobile.WIDGET_BUTTON_CLICK"
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, layoutId: Int, setViews: (RemoteViews, Context, Int) -> Unit) {
        val views = RemoteViews(context.packageName, layoutId)
        setViews(views, context, appWidgetId)

        views.let {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getProgressInfo(context: Context) {
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
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", "${semesterProgress?.completedPercentageAsInt} %")
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_1", getElapsedDaysOverTotalText(true))
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_2", getRemainingDays())
            apply()
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getCurrentText(context: Context, appWidgetId: Int): String {
        val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
        val currentVariantIndex = sharedPreferences.getInt("${Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY}_$appWidgetId", 0)
        return sharedPreferences.getString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_$currentVariantIndex", "N/A") ?: "N/A"
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getPendingIntent(context: Context, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, this::class.java).apply {
            action = WIDGET_BUTTON_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        return PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun getRemainingDays(): String {
        val remainingText = if (Constants.SEMESTER_PROGRESS_DAYS_EN == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_REMAINING_FR else Constants.SEMESTER_PROGRESS_REMAINING_EN
        return "${semesterProgress?.remainingDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN} $remainingText"
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getElapsedDaysOverTotalText(addSuffix: Boolean): String {
        if (!addSuffix) {
            return "${semesterProgress?.elapsedDays} / ${semesterProgress?.totalDays}"
        }

        val elapsedText = if (Constants.SEMESTER_PROGRESS_DAYS_EN == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_ELAPSED_FR else Constants.SEMESTER_PROGRESS_ELAPSED_EN
        return "${semesterProgress?.elapsedDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN} $elapsedText / ${semesterProgress?.totalDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN}"
    }

    abstract val layoutId: Int
    abstract val setViews: (RemoteViews, Context, Int) -> Unit

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getProgressInfo(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
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
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, this::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
        }
    }
}