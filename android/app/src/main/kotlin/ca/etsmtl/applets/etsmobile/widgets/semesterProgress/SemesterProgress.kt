package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.util.Log
import ca.etsmtl.applets.etsmobile.services.models.Semester
import java.util.Date
import java.util.concurrent.TimeUnit

class SemesterProgress {
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    var totalDays: Long = 0
    var elapsedDays: Long = 0
    var remainingDays: Long = 0
    private var completedPercentage: Double = 0.0
    var completedPercentageAsInt: Int = 0

    constructor()

    constructor(semester: Semester) : this() {
        startDate = SemesterProgressUtils.parseStringAsDate(semester.startDate!!)
        endDate = SemesterProgressUtils.parseStringAsDate(semester.endDate!!)
        calculateProgress()
    }

    private fun daysBetween(startDate: Date, endDate: Date): Long {
        val diffInMillis = endDate.time - startDate.time
        val diffInDays = TimeUnit.DAYS.convert(diffInMillis, TimeUnit.MILLISECONDS)
        return diffInDays
    }

    fun isPastEndDate(): Boolean {
        return Date().after(endDate)
    }

    fun isOngoing(): Boolean {
        val currentDate = Date()
        return (currentDate.after(startDate) || currentDate == startDate) && (currentDate.before(endDate) || currentDate == endDate)
    }

    fun calculateProgress() {
        Log.d("SemesterProgress", "Calculating progress")
        val currentDate = Date()

        // Semester hasn't started yet
        if (currentDate.before(startDate)) {
            totalDays = daysBetween(startDate, endDate)
            elapsedDays = 0
            remainingDays = totalDays
            completedPercentage = 0.0
            completedPercentageAsInt = 0
            Log.d("SemesterProgress", "Progress: ${toString()}")
            return
        }

        // Semester has started
        totalDays = daysBetween(startDate, endDate)
        elapsedDays = daysBetween(startDate, currentDate)
        remainingDays = totalDays - elapsedDays
        completedPercentage = (elapsedDays.toDouble() / totalDays.toDouble()) * 100
        completedPercentageAsInt = Math.round(completedPercentage).toInt()
        Log.d("SemesterProgress", "Progress: ${toString()}")
    }

    override fun toString(): String {
        return "{ \"startDate\": \"$startDate\", \"endDate\": \"$endDate\", \"totalDays\": $totalDays, \"elapsedDays\": $elapsedDays, \"remainingDays\": $remainingDays, \"completedPercentage\": $completedPercentage, \"completedPercentageAsInt\": $completedPercentageAsInt }"
    }

}