package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.util.Log
import ca.etsmtl.applets.etsmobile.services.SignetsService
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser

class Utils {

    companion object{
        fun getSessionProgress() {
            val user = MonETSUser(username = "username", password = "password")

            SignetsService.shared.getSessions(user) { result ->
                Log.d("SIGNETS_UTILS", "Result: $result")
                if (result.isSuccess) {
                    val sessions = result.getOrNull()
                } else {
                    val error = result.exceptionOrNull()
                }
            }
        }
    }
}