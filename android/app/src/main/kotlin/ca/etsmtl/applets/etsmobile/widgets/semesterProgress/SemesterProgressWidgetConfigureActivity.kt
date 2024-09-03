package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.Log
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.RemoteViews
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.R
import ca.etsmtl.applets.etsmobile.databinding.SemesterProgressWidgetConfigurationActivityBinding

class SemesterProgressWidgetConfigureActivity : AppCompatActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    public override fun onCreate(icicle: Bundle?) {
        super.onCreate(icicle)

        setResult(RESULT_CANCELED)

        val binding = SemesterProgressWidgetConfigurationActivityBinding.inflate(layoutInflater)
        setContentView(binding.root)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        addWidgetPreviews()
        setupThemeRadioGroup(binding)

        binding.saveButton.setOnClickListener {
            savePreferences(binding)
            updateWidget()

            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    private fun updateWidget() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val remoteViews = RemoteViews(this.packageName, R.layout.widget_semester_progress_large)

        // Check if the widget can be updated, if not log an error or handle gracefully
        if (appWidgetManager != null && appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
            // Perform widget update
            appWidgetManager.updateAppWidget(appWidgetId, remoteViews)
        } else {
            Log.e("SemesterProgressConf", "Failed to update widget: AppWidgetManager or appWidgetId is invalid")
        }
    }


    @SuppressLint("SetTextI18n")
    private fun addWidgetPreviews() {
        val smallWidget = R.layout.widget_semester_progress_small
        val largeWidget = R.layout.widget_semester_progress_large

        val smallWidgetFrameLayout = findViewById<FrameLayout>(R.id.small_widget_preview)
        val smallWidgetPreview = layoutInflater.inflate(smallWidget, smallWidgetFrameLayout, false)
        smallWidgetFrameLayout.addView(smallWidgetPreview)

        val smallWidgetProgressBar = smallWidgetPreview.findViewById<ProgressBar>(R.id.circular_progress)
        val smallWidgetProgressText = smallWidgetPreview.findViewById<TextView>(R.id.progress_text)
        val smallWidgetSecondaryText = smallWidgetPreview.findViewById<TextView>(R.id.elapsed_days_text)

        smallWidgetProgressBar.progress = 50
        smallWidgetProgressText.text = "50 %"
        smallWidgetSecondaryText.text = "50 / 100"

        val largeWidgetFrameLayout = findViewById<FrameLayout>(R.id.large_widget_preview)
        val largeWidgetPreview = layoutInflater.inflate(largeWidget, largeWidgetFrameLayout, false)
        largeWidgetFrameLayout.addView(largeWidgetPreview)

        val largeWidgetProgressBar = largeWidgetPreview.findViewById<ProgressBar>(R.id.linear_progress)
        val largeWidgetProgressText = largeWidgetPreview.findViewById<TextView>(R.id.progressText)
        largeWidgetProgressBar.progress = 50
        largeWidgetProgressText.text = "50 %"
    }

    private fun savePreferences(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        getSharedPreferences(Constants.SEMESTER_PROGRESS_PREFS_KEY, Context.MODE_PRIVATE).edit().apply {
            putString(Constants.SEMESTER_PROGRESS_THEME_KEY, getThemeValueForSave(binding))
            putString(Constants.SEMESTER_PROGRESS_LANG_KEY, getLangValueForSave(binding))
            apply()
        }
    }

    private fun getThemeValueForSave(binding: SemesterProgressWidgetConfigurationActivityBinding): String{
        val themeValue = when (binding.radioGroup.checkedRadioButtonId) {
            R.id.radio_button_dark -> Constants.SEMESTER_PROGRESS_THEME_DARK
            R.id.radio_button_light -> Constants.SEMESTER_PROGRESS_THEME_LIGHT
            else -> Constants.SEMESTER_PROGRESS_THEME_DARK
        }

        return themeValue
    }

    private fun getLangValueForSave(binding: SemesterProgressWidgetConfigurationActivityBinding): String {
        val langValue = when (binding.radioGroupLang.checkedRadioButtonId) {
            R.id.radio_button_english -> Constants.SEMESTER_PROGRESS_LANG_EN
            R.id.radio_button_french -> Constants.SEMESTER_PROGRESS_LANG_FR
            else -> Constants.SEMESTER_PROGRESS_LANG_FR
        }

        return langValue
    }

    private fun setupThemeRadioGroup(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        val radioGroup = binding.radioGroup

        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.radio_button_dark -> {
                    showDarkThemePreview(binding)
                }
                R.id.radio_button_light -> {
                    showLightThemePreview(binding)
                }
                R.id.radio_button_english -> {
                    showLargeWidgetEnglishLangPreview(binding)
                }
                R.id.radio_button_french -> {
                    showSmallWidgetFrenchLangPreview(binding)
                }
            }
        }

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

    private fun showWidgetLangPreview(
        binding: SemesterProgressWidgetConfigurationActivityBinding,
        titleTextResId: Int
    ) {
        val largeWidgetPreview = binding.largeWidgetPreview
        val largeWidgetTitleText = largeWidgetPreview.findViewById<TextView>(R.id.semester_progress_title)
        largeWidgetTitleText.setText(titleTextResId)
    }

    private fun showLargeWidgetEnglishLangPreview(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        showWidgetLangPreview(binding, R.string.semester_progress_title_en)
    }

    private fun showSmallWidgetFrenchLangPreview(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        showWidgetLangPreview(binding, R.string.semester_progress_title_fr)
    }

    private fun showThemePreview(
        binding: SemesterProgressWidgetConfigurationActivityBinding,
        backgroundColorResId: Int,
        textColor: Int
    ) {
        val smallWidgetPreview = binding.smallWidgetPreview
        val smallWidgetBackground = smallWidgetPreview.findViewById<ImageView>(R.id.widget_background)

        val largeWidgetPreview = binding.largeWidgetPreview
        val largeWidgetTitleText = largeWidgetPreview.findViewById<TextView>(R.id.semester_progress_title)
        val largeWidgetBackground = largeWidgetPreview.findViewById<ImageView>(R.id.widget_background)

        if (smallWidgetBackground == null || largeWidgetBackground == null) {
            Log.e("SemesterProgressWidget", "ImageView widget_background is null")
            return
        }

        val smallWidgetDrawable = smallWidgetBackground.drawable
        if (smallWidgetDrawable is GradientDrawable) {
            smallWidgetDrawable.setColor(ContextCompat.getColor(this, backgroundColorResId))
        }

        val largeWidgetDrawable = largeWidgetBackground.drawable
        if (largeWidgetDrawable is GradientDrawable) {
            largeWidgetDrawable.setColor(ContextCompat.getColor(this, backgroundColorResId))
        }
        largeWidgetTitleText.setTextColor(textColor)
    }

    private fun showLightThemePreview(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        showThemePreview(
            binding,
            backgroundColorResId = R.color.light_mode_background,
            textColor = Color.BLACK
        )
    }

    private fun showDarkThemePreview(binding: SemesterProgressWidgetConfigurationActivityBinding) {
        showThemePreview(
            binding,
            backgroundColorResId = R.color.dark_mode_background,
            textColor = Color.WHITE
        )
    }
}