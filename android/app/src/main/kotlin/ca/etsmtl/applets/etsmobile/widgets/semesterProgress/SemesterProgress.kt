package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.os.Build
import androidx.annotation.RequiresApi
import ca.etsmtl.applets.etsmobile.services.models.Session
import java.time.LocalDate
import java.time.temporal.ChronoUnit

class SemesterProgress (session: Session){
    @RequiresApi(Build.VERSION_CODES.O)
    private val startDate = SemesterProgressWidgetUtils.parseStringAsLocalDate(session.startDate!!)

    @RequiresApi(Build.VERSION_CODES.O)
    val endDate = SemesterProgressWidgetUtils.parseStringAsLocalDate(session.endDate!!)

    @RequiresApi(Build.VERSION_CODES.O)
    val totalDays = ChronoUnit.DAYS.between(startDate, endDate)

    @RequiresApi(Build.VERSION_CODES.O)
    var elapsedDays = ChronoUnit.DAYS.between(startDate, LocalDate.now())

    @RequiresApi(Build.VERSION_CODES.O)
    var remainingDays = ChronoUnit.DAYS.between(LocalDate.now(), endDate)

    @RequiresApi(Build.VERSION_CODES.O)
    var completedPercentage: Double = (elapsedDays.toDouble() / totalDays.toDouble()) * 100

    @RequiresApi(Build.VERSION_CODES.O)
    var completedPercentageAsInt: Int = completedPercentage.toInt()

    @RequiresApi(Build.VERSION_CODES.O)
    fun isPastEndDate(): Boolean {
        return LocalDate.now().isAfter(endDate)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun isOngoing(): Boolean {
        val currentDate = LocalDate.now()
        return (currentDate.isAfter(startDate) || currentDate.isEqual(startDate)) && (currentDate.isBefore(endDate) || currentDate.isEqual(endDate))
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun calculateProgress() {
        elapsedDays = ChronoUnit.DAYS.between(startDate, LocalDate.now())
        remainingDays = ChronoUnit.DAYS.between(LocalDate.now(), endDate)
        completedPercentage = (elapsedDays.toDouble() / totalDays.toDouble()) * 100
    }
}