package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.R
import ca.etsmtl.applets.etsmobile.databinding.SemesterProgressWidgetConfigurationActivityBinding

class SemesterProgressWidgetConfigureActivity : AppCompatActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var binding: SemesterProgressWidgetConfigurationActivityBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setResult(RESULT_CANCELED)

        try {
            binding = SemesterProgressWidgetConfigurationActivityBinding.inflate(layoutInflater)
            setContentView(binding.root)

            appWidgetId = intent?.extras?.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

            if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
                finish()
                return
            }

            setupRadioGroup(binding)

            binding.saveButton.setOnClickListener {
                savePreferences(binding)
                updateAllWidgets()

                val resultValue = Intent()
                resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                setResult(RESULT_OK, resultValue)
                finish()
            }
        } catch (e: Exception) {
            Log.e("ConfigActivity", "Exception in onCreate: ${e.message}", e)
            finish()
        }
    }

    private fun savePreferences(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
            putString(Constants.SEMESTER_PROGRESS_THEME_KEY, getThemeValueForSave(binding))
            putString(Constants.SEMESTER_PROGRESS_LANG_KEY, getLangValueForSave(binding))
            apply()
        }
    }

    private fun updateAllWidgets() {
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = ComponentName(this, SemesterProgressWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)

        sendBroadcast(intent)
    }

    private fun getThemeValueForSave(binding: SemesterProgressWidgetConfigurationActivityBinding): String {
        return when (binding.radioGroup.checkedRadioButtonId) {
            R.id.radio_button_dark -> Constants.SEMESTER_PROGRESS_THEME_DARK
            R.id.radio_button_light -> Constants.SEMESTER_PROGRESS_THEME_LIGHT
            else -> Constants.SEMESTER_PROGRESS_THEME_DARK
        }
    }

    private fun getLangValueForSave(binding: SemesterProgressWidgetConfigurationActivityBinding): String {
        return when (binding.radioGroupLang.checkedRadioButtonId) {
            R.id.radio_button_english -> Constants.SEMESTER_PROGRESS_LANG_EN
            R.id.radio_button_french -> Constants.SEMESTER_PROGRESS_LANG_FR
            else -> Constants.SEMESTER_PROGRESS_LANG_FR
        }
    }

    private fun setupRadioGroup(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        val radioGroup = binding.radioGroup

        this.getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).apply {
            val theme = getString(Constants.SEMESTER_PROGRESS_THEME_KEY, Constants.SEMESTER_PROGRESS_THEME_DARK)
            val lang = getString(Constants.SEMESTER_PROGRESS_LANG_KEY, Constants.SEMESTER_PROGRESS_LANG_FR)

            when (theme) {
                Constants.SEMESTER_PROGRESS_THEME_DARK -> radioGroup.check(R.id.radio_button_dark)
                Constants.SEMESTER_PROGRESS_THEME_LIGHT -> radioGroup.check(R.id.radio_button_light)
            }

            when (lang) {
                Constants.SEMESTER_PROGRESS_LANG_EN -> binding.radioGroupLang.check(R.id.radio_button_english)
                Constants.SEMESTER_PROGRESS_LANG_FR -> binding.radioGroupLang.check(R.id.radio_button_french)
            }
        }
    }
}
