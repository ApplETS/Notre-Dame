package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.os.Build
import androidx.annotation.RequiresApi
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.Session
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

class SemesterProgressWidgetUtils {

    companion object{
        @RequiresApi(Build.VERSION_CODES.O)
        suspend fun getSemesterProgress(): SemesterProgress?{
            return withContext(Dispatchers.IO) {
                val user = MonETSUser(username = "username", password = "password")
                suspendCancellableCoroutine { continuation ->
                    SignetsService.shared.getSessions(user) { result ->
                        if (result.isSuccess) {
                            val sessions = result.getOrNull()
                            val currentSession = getCurrentSemester(sessions)
                            if (currentSession != null) {
                                continuation.resume(SemesterProgress(currentSession))
                            } else {
                                continuation.resume(null)
                            }
                        } else {
                            val error = result.exceptionOrNull()
                            continuation.resume(null)
                        }
                    }
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
        fun parseStringAsLocalDate(date: String): LocalDate{
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
            return LocalDate.parse(date, formatter)
        }
    }
}