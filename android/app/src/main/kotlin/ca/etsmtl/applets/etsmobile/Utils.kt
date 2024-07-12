package ca.etsmtl.applets.etsmobile

import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.Date

class Utils {
    companion object {
        fun parseStringAsDate(dateString: String): Date {
            val format = SimpleDateFormat("yyyy-MM-dd")
            return try {
                format.parse(dateString)!!
            } catch (e: ParseException) {
                Date()
            }
        }
    }
}