package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.os.Build
import androidx.annotation.RequiresApi
import java.time.LocalDate
import java.time.Period

class SemesterProgress (startDate: LocalDate, endDate: LocalDate){
    @RequiresApi(Build.VERSION_CODES.O)
    val totalDays = Period.between(startDate, endDate).days

    @RequiresApi(Build.VERSION_CODES.O)
    val elapsedDays = Period.between(startDate, LocalDate.now()).days

    @RequiresApi(Build.VERSION_CODES.O)
    val remainingDays = Period.between(LocalDate.now(), endDate).days

    @RequiresApi(Build.VERSION_CODES.O)
    val completedPercentage: Double = (elapsedDays.toDouble() / totalDays.toDouble()) * 100
}