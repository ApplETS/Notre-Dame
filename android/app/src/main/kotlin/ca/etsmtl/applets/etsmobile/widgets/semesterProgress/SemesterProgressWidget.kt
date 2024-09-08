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
        if (minWidth < 200) {
            views = RemoteViews(context.packageName, R.layout.semester_progress_widget_small)
            semesterProgress?.let {
                views.setTextViewText(R.id.secondary_progress_text, "${it.elapsedDays} / ${it.totalDays}")
                views.setTextViewText(R.id.progress_text, "${it.completedPercentageAsInt} %")
            }

        } else {
            views = RemoteViews(context.packageName, R.layout.semester_progress_widget_large)
            views.setTextViewText(R.id.progress_text, getCurrentProgressTextFromSharedPreferences(context))
            views.setTextColor(R.id.large_semester_progress_title, getTextColorFromSharedPreferences(context))
            semesterProgress?.let {
                views.setTextViewText(R.id.large_semester_progress_title, getTitleText(context))
            }
        }

        semesterProgress?.let {
            views.setProgressBar(R.id.progression, 100, it.completedPercentageAsInt, false)
        }

        // Set background color
        views.setInt(R.id.widget_root, "setBackgroundResource", getBackgroundResource(context))

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
            updatesProgressesInSharedPrefs(context)
            updateAllWidgets(context)
        } else {
            // Fetch new data and calculate progress if the semester is not ongoing
            CoroutineScope(Dispatchers.IO).launch {
                semesterProgress = fetchSemesterProgress(context)
                semesterProgress?.calculateProgress()
                updatesProgressesInSharedPrefs(context)

                withContext(Dispatchers.Main) {
                    updateAllWidgets(context)
                }
            }
        }
    }

    private fun updatesProgressesInSharedPrefs(context: Context) {
        context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
            putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", "${semesterProgress?.completedPercentageAsInt} %")
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
        val language = getLanguagePreference(context)
        val remainingDays = semesterProgress?.remainingDays ?: 0

        return when (language) {
            Constants.SHARED_PREFERENCES_LANG_FR -> {
                "$remainingDays ${Constants.SEMESTER_PROGRESS_REMAINING_FR}"
            }
            Constants.SHARED_PREFERENCES_LANG_EN -> {
                "$remainingDays ${Constants.SEMESTER_PROGRESS_REMAINING_EN}"
            }
            else -> {
                "$remainingDays ${Constants.SEMESTER_PROGRESS_REMAINING_FR}"
            }
        }
    }

    private fun getElapsedDaysOverTotalText(context: Context): String {
        val language = getLanguagePreference(context)
        val elapsedDays = semesterProgress?.elapsedDays ?: 0
        val totalDays = semesterProgress?.totalDays ?: 0

        return when (language) {
            Constants.SHARED_PREFERENCES_LANG_FR -> {
                "$elapsedDays ${Constants.SEMESTER_PROGRESS_ELAPSED_FR} / $totalDays ${Constants.SEMESTER_PROGRESS_DAYS_FR}"
            }
            Constants.SHARED_PREFERENCES_LANG_EN -> {
                "$elapsedDays ${Constants.SEMESTER_PROGRESS_ELAPSED_EN} / $totalDays ${Constants.SEMESTER_PROGRESS_DAYS_EN}"
            }
            else -> {
                "$elapsedDays ${Constants.SEMESTER_PROGRESS_ELAPSED_FR} / $totalDays ${Constants.SEMESTER_PROGRESS_DAYS_FR}"
            }
        }
    }

    private fun getBackgroundResource(context: Context): Int {
        val theme = getThemePref(context)
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
        val theme = getThemePref(context)
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

    private fun getTitleText(context: Context): String {
        val language = getLanguagePreference(context)
        return when (language) {
            Constants.SHARED_PREFERENCES_LANG_FR -> {
                Constants.SEMESTER_PROGRESS_TITLE_FR
            }
            Constants.SHARED_PREFERENCES_LANG_EN -> {
                Constants.SEMESTER_PROGRESS_TITLE_EN
            }
            else -> {
                Constants.SEMESTER_PROGRESS_TITLE_FR
            }
        }
    }

    private fun getLanguagePreference(context: Context): String {
        return context.getSharedPreferences(Constants.SHARED_PREFERENCES_FILE, Context.MODE_PRIVATE)
            .getString(Constants.SHARED_PREFERENCES_LANG_KEY, Constants.SHARED_PREFERENCES_LANG_FR) ?: Constants.SHARED_PREFERENCES_LANG_FR
    }

    private fun getThemePref(context: Context): String {
        return context.getSharedPreferences(Constants.SHARED_PREFERENCES_FILE, Context.MODE_PRIVATE)
            .getString(Constants.SHARED_PREFERENCES_THEME_KEY, Constants.SHARED_PREFERENCES_THEME_LIGHT) ?: Constants.SHARED_PREFERENCES_THEME_LIGHT
    }
}