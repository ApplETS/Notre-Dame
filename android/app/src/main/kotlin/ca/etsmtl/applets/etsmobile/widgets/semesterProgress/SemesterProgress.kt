package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.util.Log
import ca.etsmtl.applets.etsmobile.Utils
import ca.etsmtl.applets.etsmobile.services.models.Semester
import java.util.Date

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
        startDate = Utils.parseStringAsDate(semester.startDate!!)
        endDate = Utils.parseStringAsDate(semester.endDate!!)
        calculateProgress()
    }

    private fun daysBetween(startDate: Date, endDate: Date): Long {
        val diff = endDate.time - startDate.time
        return diff / (1000 * 60 * 60 * 24)
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
        elapsedDays = daysBetween(startDate, currentDate)
        remainingDays = daysBetween(currentDate, endDate)
        totalDays = daysBetween(startDate, endDate)
        completedPercentage = (elapsedDays.toDouble() / totalDays.toDouble()) * 100
        completedPercentageAsInt = Math.round(completedPercentage).toInt()
        Log.d("SemesterProgress", "Progress: ${toString()}")
    }

    override fun toString(): String {
        return "{ \"startDate\": \"$startDate\", \"endDate\": \"$endDate\", \"totalDays\": $totalDays, \"elapsedDays\": $elapsedDays, \"remainingDays\": $remainingDays, \"completedPercentage\": $completedPercentage, \"completedPercentageAsInt\": $completedPercentageAsInt }"
    }

}