package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.annotation.SuppressLint
import android.util.Log
import ca.etsmtl.applets.etsmobile.services.models.Semester
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date

class SemesterProgressUtils {
    companion object{
        @SuppressLint("SimpleDateFormat")
        fun parseStringAsDate(dateString: String): Date {
            val format = SimpleDateFormat("yyyy-MM-dd")
            return format.parse(dateString)!!
        }

        fun findSemester(semesters: List<Semester>?): Semester?{
            if (semesters.isNullOrEmpty()){
                return null
            }

            for (session in semesters) {
                val startDate = parseStringAsDate(session.startDate!!)
                val endDate = parseStringAsDate(session.endDate!!)

                Log.d("SemesterProgressWidget", "Checking semester: $session")

                if (isTodayBetweenSemesterStartAndEnd(startDate, endDate)){
                    Log.d("SemesterProgressWidget", "Found current semester: $session")
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
            val startDate = parseStringAsDate(upcomingSemester.startDate!!)

            if (today.before(startDate)) {
                return upcomingSemester
            }

            return null
        }

        private fun isTodayBetweenSemesterStartAndEnd(startDate: Date, endDate: Date): Boolean {
            val today = setDateToMidnight(Calendar.getInstance().time)
            val start = setDateToMidnight(startDate)
            val end = setDateToMidnight(endDate)

            return (today == start || today.after(start)) && (today == end || today.before(end))
        }

        private fun setDateToMidnight(date: Date): Date {
            val calendar = Calendar.getInstance()
            calendar.time = date
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            return calendar.time
        }
    }
}