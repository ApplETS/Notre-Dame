package ca.etsmtl.applets.etsmobile

import android.content.Context
import androidx.annotation.LayoutRes

class ListSharedPrefsUtil {
    companion object {
        private const val WIDGET_PREFS = "widget_prefs"
        public const val WIDGET_BACKGROUND_COLOR = "widget_background_color"
        public const val WIDGET_TEXT_COLOR = "widget_text_color"

        fun saveSemesterProgressWidgetTheme(context: Context, appWidgetId: Int, backgroundColor: Int, textColor: Int) {
            val prefs = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
            prefs.edit().putInt(WIDGET_BACKGROUND_COLOR, backgroundColor).apply()
            prefs.edit().putInt(WIDGET_TEXT_COLOR, textColor).apply()
        }

        fun getSemesterProgressWidgetTheme(context: Context, appWidgetId: Int): Pair<Int, Int> {
            val prefs = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
            val backgroundColor = prefs.getInt(WIDGET_BACKGROUND_COLOR, 0)
            val textColor = prefs.getInt(WIDGET_TEXT_COLOR, 0)
            return Pair(backgroundColor, textColor)
        }
    }
}