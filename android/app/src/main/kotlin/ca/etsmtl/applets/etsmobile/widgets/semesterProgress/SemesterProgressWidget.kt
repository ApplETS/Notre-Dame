package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.R
import ca.etsmtl.applets.etsmobile.SecureStorageHelper
import ca.etsmtl.applets.etsmobile.Utilities.Companion.getAppTheme
import ca.etsmtl.applets.etsmobile.Utilities.Companion.getLocalizedString
import ca.etsmtl.applets.etsmobile.Utilities.Companion.isInternetAvailable
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

class SemesterProgressWidget : AppWidgetProvider() {
    companion object {
        var semesterProgress: SemesterProgress? = null
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getAndUpdateProgress(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (Constants.WIDGET_BUTTON_CLICK == intent.action) {
            val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
                val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)

                getAndUpdateProgress(context)
                if (minWidth >= 200) {
                    cycleText(context, appWidgetManager, appWidgetId)
                }
            }
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val views: RemoteViews

        // Choose the layout based on the widget's size
        val progress = semesterProgress?.completedPercentageAsInt ?: 0
        if (minWidth < 200) {
            views = RemoteViews(context.packageName, R.layout.semester_progress_widget_small)
            val percentageText = semesterProgress?.completedPercentageAsInt?.let { "$it %" } ?: "N/A"
            val secondaryText = semesterProgress?.let {
                it.elapsedDays.let { elapsed ->
                    it.totalDays.let { total -> "$elapsed / $total" }
                }
            } ?: "N/A"

            views.setTextViewText(R.id.progress_text, percentageText)
            views.setTextViewText(R.id.secondary_progress_text, secondaryText)

        } else {
            views = RemoteViews(context.packageName, R.layout.semester_progress_widget_large)
            views.setTextViewText(R.id.progress_text, getCurrentProgressTextFromSharedPreferences(context))
        }

        views.setProgressBar(R.id.progression, 100, progress, false)

        // Set colors
        views.setTextColor(R.id.large_semester_progress_title, getTextColorFromSharedPreferences(context))
        views.setInt(R.id.widget_root, "setBackgroundResource", getBackgroundResource(context))
        views.setTextViewText(R.id.large_semester_progress_title, getLocalizedString(context, R.string.semester_progress_title))

        // Set up the click listener
        val clickIntent = Intent(context, SemesterProgressWidget::class.java).apply {
            action = Constants.WIDGET_BUTTON_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val pendingClickIntent = PendingIntent.getBroadcast(context, appWidgetId, clickIntent, PendingIntent.FLAG_IMMUTABLE)

        views.setOnClickPendingIntent(R.id.widget_root, pendingClickIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, this::class.java))
        appWidgetIds.forEach { updateAppWidget(context, appWidgetManager, it) }
    }

    private fun getAndUpdateProgress(context: Context) {
        if (semesterProgress != null && semesterProgress!!.isOngoing()) {
            semesterProgress!!.calculateProgress()
            updateProgressesInSharedPrefs(context)
            updateAllWidgets(context)
        } else if (isInternetAvailable(context)) {
            // Fetch new data and calculate progress if the semester is not ongoing
            CoroutineScope(Dispatchers.IO).launch {
                semesterProgress = fetchSemesterProgress(context)
                semesterProgress?.calculateProgress()
                updateProgressesInSharedPrefs(context)

                withContext(Dispatchers.Main) {
                    updateAllWidgets(context)
                }
            }
        }
        else{
            // Semester is null or not ongoing and no internet connection to call the API
            semesterProgress = null
            updateAllWidgets(context)
        }
    }

    private fun updateProgressesInSharedPrefs(context: Context) {
        val percentageText = semesterProgress?.completedPercentageAsInt?.let { "$it %" } ?: "N/A"

        context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", percentageText)
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_1", getElapsedDaysOverTotalText(context))
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_2", getRemainingDaysText(context))
            apply()
        }
    }

    private suspend fun fetchSemesterProgress(context: Context): SemesterProgress? {
        Log.d("SemesterProgressWidget", "Fetching semester progress")

        val secureStorageHelper = SecureStorageHelper()
        val username = secureStorageHelper.getValue(context, Constants.USERNAME_KEY)
        val password = secureStorageHelper.getValue(context, Constants.PASSWORD_KEY)

        if (username == null || password == null) {
            return null
        }

        val user = MonETSUser(username, password)
        return withContext(Dispatchers.IO) {
            suspendCancellableCoroutine { continuation ->
                SignetsService.shared.getSessions(user) { result ->
                    if (result.isFailure) {
                        continuation.resume(null)
                    }
                    else {
                        val currentSemester = result.getOrNull()?.let { SemesterProgressUtils.findSemester(it) }
                        continuation.resume(currentSemester?.let { SemesterProgress(it) })
                    }
                }
            }
        }
    }

    private fun cycleText(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
        val currentVariantIndex = sharedPreferences.getInt(Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY, 0)
        val newVariantIndex = (currentVariantIndex + 1) % (Constants.MAX_PROGRESS_VARIANT_INDEX + 1)

        sharedPreferences.edit().putInt(Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY, newVariantIndex).apply()

        val newText = sharedPreferences.getString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_$newVariantIndex", "N/A") ?: "N/A"

        val views = RemoteViews(context.packageName, R.layout.semester_progress_widget_large)
        views.setTextViewText(R.id.progress_text, newText)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getCurrentProgressTextFromSharedPreferences(context: Context): String {
        val sharedPreferences = context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
        val currentVariantIndex = sharedPreferences.getInt(Constants.SEMESTER_PROGRESS_CURRENT_VARIANT_KEY, 0)
        val progressText = sharedPreferences.getString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_$currentVariantIndex", "N/A") ?: "N/A"

        return progressText
    }

    private fun getRemainingDaysText(context: Context): String {
        val remainingDays = semesterProgress?.remainingDays ?: return "N/A"
        val remainingText = getLocalizedString(context, R.string.semester_progress_days_remaining)
        return "$remainingDays $remainingText"
    }

    private fun getElapsedDaysOverTotalText(context: Context): String {
        val elapsedDays = semesterProgress?.elapsedDays ?: return "N/A"
        val totalDays = semesterProgress?.totalDays ?: return "N/A"
        val elapsedText = getLocalizedString(context, R.string.semester_progress_days_elapsed)
        val daysText = getLocalizedString(context, R.string.semester_progress_days)
        return "$elapsedDays $elapsedText / $totalDays $daysText"
    }

    private fun getBackgroundResource(context: Context): Int {
        val theme = getAppTheme(context)
        return when (theme) {
            Constants.SHARED_PREFERENCES_THEME_LIGHT -> {
                R.drawable.rounded_rec_light
            }
            Constants.SHARED_PREFERENCES_THEME_DARK -> {
                R.drawable.rounded_rec_dark
            }
            else -> {
                R.drawable.rounded_rec_light
            }
        }
    }

    private fun getTextColorFromSharedPreferences(context: Context): Int {
        val theme = getAppTheme(context)
        return when (theme) {
            Constants.SHARED_PREFERENCES_THEME_LIGHT -> {
                Color.BLACK
            }
            Constants.SHARED_PREFERENCES_THEME_DARK -> {
                Color.WHITE
            }
            else -> {
                Color.BLACK
            }
        }
    }
}