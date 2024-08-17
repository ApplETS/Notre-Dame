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
import android.widget.Toast
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.Semester
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.Date
import kotlin.coroutines.resume

abstract class SemesterProgressWidgetBase : AppWidgetProvider() {
    companion object {
        var semesterProgress = SemesterProgress()
    }

    fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, layoutId: Int, setViews: (RemoteViews, Context, Int) -> Unit) {
        val views = RemoteViews(context.packageName, layoutId)
        setViews(views, context, appWidgetId)

        views.let {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    fun getProgressInfo(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            // TODO : Handle case when there's an error fetching the data
            if (semesterProgress.isOngoing()){
                semesterProgress.calculateProgress()
            }
            else{
                val progress = getSemesterProgress(context)
                if (progress == null) {
                    withContext(Dispatchers.Main){
                        Toast.makeText(context, "Error fetching semester progress", Toast.LENGTH_SHORT).show()
                    }
                    semesterProgress = SemesterProgress()
                }
                else{
                    semesterProgress = progress
                }
            }

            context.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_0", "${semesterProgress.completedPercentageAsInt} %")
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_1", getElapsedDaysOverTotalText(true))
                putString("${Constants.SEMESTER_PROGRESS_VARIANT_KEY}_2", getRemainingDaysText())
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

    private fun getRemainingDaysText(): String {
        val remainingText = if (Constants.SEMESTER_PROGRESS_DAYS_EN == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_REMAINING_FR else Constants.SEMESTER_PROGRESS_REMAINING_EN
        return "${semesterProgress.remainingDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN} $remainingText"
    }

    private fun getElapsedDaysOverTotalText(addSuffix: Boolean): String {
        if (!addSuffix) {
            return "${semesterProgress.elapsedDays} / ${semesterProgress.totalDays}"
        }

        val elapsedText = if (Constants.SEMESTER_PROGRESS_DAYS_EN == Constants.SEMESTER_PROGRESS_DAYS_FR) Constants.SEMESTER_PROGRESS_ELAPSED_FR else Constants.SEMESTER_PROGRESS_ELAPSED_EN
        return "${semesterProgress.elapsedDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN} $elapsedText / ${semesterProgress.totalDays} ${Constants.SEMESTER_PROGRESS_DAYS_EN}"
    }

    abstract val layoutId: Int
    abstract val setViews: (RemoteViews, Context, Int) -> Unit

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        getProgressInfo(context)
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

    private fun updateAllAppWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, this::class.java))
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, layoutId, setViews)
        }
    }

    private suspend fun getSemesterProgress(context: Context): SemesterProgress? {
        Log.d("SemesterProgressWidget", "Fetching semester progress")
        val user = MonETSUser("username", "password")

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
                    val currentSemester = findSemester(sessions)
                    if (currentSemester == null) {
                        continuation.resume(null)
                    } else {
                        continuation.resume(SemesterProgress(currentSemester))
                    }
                }
            }
        }
    }

    private fun findSemester(semesters: List<Semester>?): Semester?{
        if (semesters.isNullOrEmpty()){
            return null
        }

        for (session in semesters) {
            val startDate = SemesterProgressUtils.parseStringAsDate(session.startDate!!)
            val endDate = SemesterProgressUtils.parseStringAsDate(session.endDate!!)

            if (isTodayBetweenSemesterStartAndEnd(startDate, endDate)){
                return session
            }
        }

        // Check for upcoming semester that hasn't started yet
        return getUpcomingSemester(semesters)
    }

    private fun getUpcomingSemester(semesters: List<Semester>?): Semester? {
        if (semesters.isNullOrEmpty()) {
            return null
        }

        val upcomingSemester = semesters.last()
        val today = Calendar.getInstance().time
        val startDate = SemesterProgressUtils.parseStringAsDate(upcomingSemester.startDate!!)

        if (today.before(startDate)) {
            return upcomingSemester
        }

        return null
    }

    private fun isTodayBetweenSemesterStartAndEnd(startDate: Date, endDate: Date): Boolean {
        val today = Calendar.getInstance().time
        return (today.equals(startDate) || today.after(startDate)) && (today.equals(endDate) || today.before(endDate))
    }
}