package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.SecureStorageHelper
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

abstract class SemesterProgressWidgetBase : AppWidgetProvider() {
    companion object {
        var semesterProgress: SemesterProgress? = null
    }

    fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, layoutId: Int, setViews: (RemoteViews, Context, Int) -> Unit) {
        val views = RemoteViews(context.packageName, layoutId)
        setViews(views, context, appWidgetId)

        views.let {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    fun getSemesterProgress(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            if (semesterProgress != null && semesterProgress!!.isOngoing()) {
                semesterProgress!!.calculateProgress()
            }

            // The semester progress is null or the current semester has ended.
            // In any case, we try to fetch the data.
            // There's either an active semester or an upcoming one.
            else{
                semesterProgress = getProgressData(context)
            }

            // TODO : Handle case when there's an error fetching the data

            context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", "${semesterProgress?.completedPercentageAsInt} %")
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_1", getElapsedDaysOverTotalText(context))
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_2", getRemainingDaysText(context))
                apply()
            }

            // Update all widgets after data is fetched
            updateAllAppWidgets(context)
        }
    }

    fun getPendingIntent(context: Context, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, this::class.java).apply {
            action = Constants.WIDGET_BUTTON_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        return PendingIntent.getBroadcast(context, appWidgetId, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    private fun getRemainingDaysText(context: Context): String {
        val language = getLanguagePreference(context)
        val remainingDays = semesterProgress?.remainingDays ?: 0

        return when (language) {
            "FR" -> {
                "$remainingDays jours restants"
            }
            "EN" -> {
                "$remainingDays days remaining"
            }
            else -> {
                "$remainingDays jours restants"
            }
        }
    }

    private fun getElapsedDaysOverTotalText(context: Context): String {
        val language = getLanguagePreference(context)
        val elapsedDays = semesterProgress?.elapsedDays ?: 0
        val totalDays = semesterProgress?.totalDays ?: 0

        return when (language) {
            "FR" -> {
                "$elapsedDays jours écoulés / $totalDays jours"
            }
            "EN" -> {
                "$elapsedDays days elapsed / $totalDays days"
            }
            else -> {
                "$elapsedDays jours écoulés / $totalDays jours"
            }
        }
    }

    abstract val layoutId: Int
    abstract val setViews: (RemoteViews, Context, Int) -> Unit

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getSemesterProgress(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateAllAppWidgets(context)
    }

    private fun getLanguagePreference(context: Context): String {
        return context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE)
            .getString(Constants.SEMESTER_PROGRESS_LANG_KEY, "FR") ?: "FR"
    }

    private fun updateAllAppWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, this::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
        }
    }

    private suspend fun getProgressData(context: Context): SemesterProgress? {
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
                var isResumed = false
                SignetsService.shared.getSessions(user) { result ->
                    if (isResumed) {
                        return@getSessions
                    }

                    isResumed = true

                    if (result.isFailure) {
                        continuation.resume(null)
                        return@getSessions
                    }

                    val sessions = result.getOrNull()
                    val currentSemester = SemesterProgressUtils.findSemester(sessions)
                    if (currentSemester == null) {
                        continuation.resume(null)
                    } else {
                        continuation.resume(SemesterProgress(currentSemester))
                    }
                }
            }
        }
    }


}