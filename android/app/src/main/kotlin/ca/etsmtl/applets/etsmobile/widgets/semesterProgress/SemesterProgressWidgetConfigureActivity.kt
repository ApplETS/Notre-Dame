package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setResult(RESULT_CANCELED)

        try {
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

    @SuppressLint("SetTextI18n")
    private fun addWidgetPreviews() {
        val smallWidgetLayout = R.layout.semester_progress_widget_small
        val largeWidgetLayout = R.layout.semester_progress_widget_large

        // Small widget preview
        val smallWidgetFrameLayout = findViewById<FrameLayout>(R.id.small_widget_preview)

        // Set dimensions for the small widget preview
        val smallWidgetLayoutParams = FrameLayout.LayoutParams(
            resources.getDimensionPixelSize(R.dimen.semester_progress_widget_small_width),
            resources.getDimensionPixelSize(R.dimen.semester_progress_widget_small_height)
        )
        smallWidgetFrameLayout.layoutParams = smallWidgetLayoutParams

        val smallWidgetPreview = layoutInflater.inflate(smallWidgetLayout, smallWidgetFrameLayout, false)
        smallWidgetFrameLayout.addView(smallWidgetPreview)

        val smallWidgetProgressBar = smallWidgetPreview.findViewById<ProgressBar>(R.id.progression)
        val smallWidgetProgressText = smallWidgetPreview.findViewById<TextView>(R.id.progress_text)
        val smallWidgetSecondaryText = smallWidgetPreview.findViewById<TextView>(R.id.secondary_progress_text)

        // Set up small widget preview content
        smallWidgetProgressBar.progress = 50
        smallWidgetProgressText.text = "50 %"
        smallWidgetSecondaryText.text = "50 / 100"

        // Large widget preview
        val largeWidgetFrameLayout = findViewById<FrameLayout>(R.id.large_widget_preview)

        // Set dimensions for the large widget preview
        val largeWidgetLayoutParams = FrameLayout.LayoutParams(
            resources.getDimensionPixelSize(R.dimen.semester_progress_widget_large_width),
            resources.getDimensionPixelSize(R.dimen.semester_progress_widget_large_height)
        )
        largeWidgetFrameLayout.layoutParams = largeWidgetLayoutParams

        val largeWidgetPreview = layoutInflater.inflate(largeWidgetLayout, largeWidgetFrameLayout, false)
        largeWidgetFrameLayout.addView(largeWidgetPreview)

        val largeWidgetProgressBar = largeWidgetPreview.findViewById<ProgressBar>(R.id.progression)
        val largeWidgetProgressText = largeWidgetPreview.findViewById<TextView>(R.id.progress_text)

        // Set up large widget preview content
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

    private fun updateAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = ComponentName(this, SemesterProgressWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

        for (appWidgetId in appWidgetIds) {
            val smallRemoteViews = RemoteViews(this.packageName, R.layout.semester_progress_widget_small)
            val largeRemoteViews = RemoteViews(this.packageName, R.layout.semester_progress_widget_large)

            appWidgetManager.updateAppWidget(appWidgetId, smallRemoteViews)
            appWidgetManager.updateAppWidget(appWidgetId, largeRemoteViews)
        }
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
