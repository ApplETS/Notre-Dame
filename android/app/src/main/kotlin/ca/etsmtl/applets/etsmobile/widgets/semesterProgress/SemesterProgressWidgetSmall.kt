package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.content.Context
import android.os.Build
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import ca.etsmtl.applets.etsmobile.R

class SemesterProgressWidgetSmall : SemesterProgressWidgetBase() {
    override val layoutId: Int
        get() = R.layout.widget_semester_progress_small

    override val setViews: (RemoteViews, Context, Int) -> Unit
        @RequiresApi(Build.VERSION_CODES.O)
        get() = { views, context, appWidgetId ->
            semesterProgress?.completedPercentageAsInt?.let {
                views.setProgressBar(R.id.progressBar, 100, it, false)
            }
            views.setTextViewText(R.id.progress_text, "${semesterProgress?.completedPercentageAsInt} %")
            views.setTextViewText(R.id.elapsed_days_text, "${semesterProgress?.elapsedDays} / ${semesterProgress?.totalDays}")
        }
}