package ca.etsmtl.applets.etsmobile.widgets.semesterProgress

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import ca.etsmtl.applets.etsmobile.ListSharedPrefsUtil
import ca.etsmtl.applets.etsmobile.R
import ca.etsmtl.applets.etsmobile.databinding.SemesterProgressLargeConfigurationActivityBinding

class SemesterProgressWidgetLargeConfigureActivity : AppCompatActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    public override fun onCreate(icicle: Bundle?) {
        super.onCreate(icicle)

        // If the user presses the back button, the activity cancels
        setResult(RESULT_CANCELED)

        // TODO : Allow choosing background and text color
        val binding = SemesterProgressLargeConfigurationActivityBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Find the widget id from the intent.
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        // If this activity was started with an intent without an app widget ID, finish with an error.
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setupThemeRadioGroup(binding)
        addWidgetPreviews()

        binding.saveButton.setOnClickListener {
            // It is the responsibility of the configuration activity to update the app widget
            val appWidgetManager = AppWidgetManager.getInstance(this)
//            SemesterProgressWidgetLarge.updateAppWidget(this, appWidgetManager, appWidgetId)

            // Make sure we pass back the original appWidgetId
            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun addWidgetPreviews() {
        val widget = R.layout.widget_semester_progress_large

        val frameLayout = findViewById<FrameLayout>(R.id.widget_preview_large)
        val preview = layoutInflater.inflate(widget, frameLayout, false)
        frameLayout.addView(preview)

        // TODO : Cycle between list of strings when progress is clicked
        val progressBar = preview.findViewById<ProgressBar>(R.id.progressBar)
        val progressText = preview.findViewById<TextView>(R.id.progressText)

        progressBar.progress = 50
        progressText.text = "50 %"
    }

    private fun setupThemeRadioGroup(binding: SemesterProgressLargeConfigurationActivityBinding) {
        val radioGroup = binding.radioGroup
        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.radio_button_dark -> {
                    val backgroundColor = ContextCompat.getColor(this, R.color.dark_mode_card)
                    val titleTextColor = Color.WHITE
                    ListSharedPrefsUtil.saveSemesterProgressWidgetTheme(
                        this, appWidgetId,
                        backgroundColor, titleTextColor
                    )
                    toggleWidgetPreviewTheme(binding, backgroundColor, titleTextColor)
                }
                R.id.radio_button_light -> {
                    val backgroundColor = ContextCompat.getColor(this,
                        R.color.light_mode_background
                    )
                    val titleTextColor = Color.BLACK
                    ListSharedPrefsUtil.saveSemesterProgressWidgetTheme(
                        this, appWidgetId,
                        backgroundColor, titleTextColor
                    )
                    toggleWidgetPreviewTheme(binding, backgroundColor, titleTextColor)
                }
            }
        }
    }

    private fun toggleWidgetPreviewTheme(
        binding: SemesterProgressLargeConfigurationActivityBinding,
        backgroundColor: Int,
        titleTextColor: Int) {
        val preview = binding.widgetPreviewLarge

        val previewBackground = preview.findViewById<ImageView>(R.id.widget_background)
        val drawable = previewBackground.drawable
        val titleText = preview.findViewById<TextView>(R.id.semester_progress_title)

        if (drawable is GradientDrawable) {
            drawable.setColor(backgroundColor)
        }

        previewBackground.setImageDrawable(drawable)
        titleText.setTextColor(titleTextColor)
    }
}