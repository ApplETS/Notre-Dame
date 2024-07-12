package ca.etsmtl.applets.etsmobile

import android.os.Build
import androidx.annotation.RequiresApi
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class Utils {
    companion object {
        @RequiresApi(Build.VERSION_CODES.O)
        fun parseStringAsLocalDate(date: String): LocalDate {
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
            return LocalDate.parse(date, formatter)
        }
    }
}