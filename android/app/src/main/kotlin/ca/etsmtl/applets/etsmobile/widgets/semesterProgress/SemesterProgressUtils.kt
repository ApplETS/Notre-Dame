package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.annotation.SuppressLint
import java.text.SimpleDateFormat
import java.util.Date

class SemesterProgressUtils {
    companion object{
        @SuppressLint("SimpleDateFormat")
        fun parseStringAsDate(dateString: String): Date {
            val format = SimpleDateFormat("yyyy-MM-dd")
            return format.parse(dateString)!!
        }
    }
}