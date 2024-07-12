package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.content.Context
import android.widget.RemoteViews
import ca.etsmtl.applets.etsmobile.R

class SemesterProgressWidgetSmall : SemesterProgressWidgetBase() {
    override val layoutId: Int
        get() = R.layout.widget_semester_progress_small

    private fun getPercentageText(): String {
        return "${semesterProgress.completedPercentageAsInt} %"
    }

    private fun getElapsedDaysText(): String {
        return "${semesterProgress.elapsedDays} / ${semesterProgress.totalDays}"
    }

    override val setViews: (RemoteViews, Context, Int) -> Unit
        get() = { views, _, _ ->
            views.setProgressBar(R.id.progressBar, 100, semesterProgress.completedPercentageAsInt, false)
            views.setTextViewText(R.id.progress_text, getPercentageText())
            views.setTextViewText(R.id.elapsed_days_text, getElapsedDaysText())
        }
}