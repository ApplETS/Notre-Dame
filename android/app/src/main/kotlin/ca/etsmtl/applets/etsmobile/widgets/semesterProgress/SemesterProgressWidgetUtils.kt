package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.Session
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class Utils {

    companion object{
        @RequiresApi(Build.VERSION_CODES.O)
        fun getSemesterProgress() {
            val user = MonETSUser(username = "username", password = "password")

            SignetsService.shared.getSessions(user) { result ->
                if (result.isSuccess) {
                    val sessions = result.getOrNull()
                    val currentSession = getCurrentSemester(sessions)
                    val startDate = parseStringAsLocalDate(currentSession?.startDate!!)
                    val endDate = parseStringAsLocalDate(currentSession.endDate!!)
                    val semesterProgress = SemesterProgress(startDate, endDate)
                    Log.d("Progress", "${semesterProgress.totalDays} ${semesterProgress.elapsedDays} ${semesterProgress.remainingDays} ${semesterProgress.completedPercentage}")
                } else {
                    val error = result.exceptionOrNull()
                }
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        fun getCurrentSemester(sessions: List<Session>?): Session?{
            if (sessions != null) {
                for (session in sessions) {
                    val startDate = parseStringAsLocalDate(session.startDate!!)
                    val endDate = parseStringAsLocalDate(session.endDate!!)

                    if (isTodayBetweenSemesterStartAndEnd(startDate, endDate)){
                        Log.d("Current Session", session.name.toString())
                        return session
                    }
                }
            }

            return null
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun isTodayBetweenSemesterStartAndEnd(startDate: LocalDate, endDate: LocalDate): Boolean{
            val today = LocalDate.now()
            return (today.isEqual(startDate) || today.isAfter(startDate)) && (today.isEqual(endDate) || today.isBefore(endDate))
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun parseStringAsLocalDate(date: String): LocalDate{
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
            return LocalDate.parse(date, formatter)
        }
    }
}