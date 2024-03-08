package ca.etsmtl.applets.etsmobile

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import ca.etsmtl.applets.etsmobile.databinding.SemesterProgressConfigurationActivityBinding

class ProgressWidgetConfigureActivity : AppCompatActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    public override fun onCreate(icicle: Bundle?) {
        super.onCreate(icicle)

        // If the user presses the back button, the activity cancels
        setResult(RESULT_CANCELED)

        val binding = SemesterProgressConfigurationActivityBinding.inflate(layoutInflater)
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
            ProgressWidget.updateAppWidget(this, appWidgetManager, appWidgetId)

            // Make sure we pass back the original appWidgetId
            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun addWidgetPreviews() {
        val smallWidget = R.layout.widget_semester_progress_small
        val largeWidget = R.layout.widget_semester_progress_large

        val smallFrameLayout = findViewById<FrameLayout>(R.id.widget_preview_small)
        val widgetPreviewSmall = layoutInflater.inflate(smallWidget, smallFrameLayout, false)
        smallFrameLayout.addView(widgetPreviewSmall)

        val largeFrameLayout = findViewById<FrameLayout>(R.id.widget_preview_large)
        val widgetPreviewLarge = layoutInflater.inflate(largeWidget, largeFrameLayout, false)
        largeFrameLayout.addView(widgetPreviewLarge)

        val progressBarSmall = widgetPreviewSmall.findViewById<ProgressBar>(R.id.progressBar)
        val progressTextSmall = widgetPreviewSmall.findViewById<TextView>(R.id.progress_text)
        val elapsedDaysTextSmall = widgetPreviewSmall.findViewById<TextView>(R.id.elapsed_days_text)

        val progressBarLarge = widgetPreviewLarge.findViewById<ProgressBar>(R.id.progressBar)
        val progressTextLarge = widgetPreviewLarge.findViewById<TextView>(R.id.progressText)

        progressBarSmall.progress = 50
        progressTextSmall.text = "50 %"
        elapsedDaysTextSmall.text = "50 / 100"

        progressBarLarge.progress = 50
        progressTextLarge.text = "50 %"
    }

    private fun setupThemeRadioGroup(binding: SemesterProgressConfigurationActivityBinding) {
        val radioGroup = binding.radioGroup
        radioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.radio_button_dark -> {
                    val backgroundColor = ContextCompat.getColor(this, R.color.dark_mode_card)
                    val titleTextColor = Color.WHITE
                    ListSharedPrefsUtil.saveSemesterProgressWidgetTheme(this, appWidgetId,
                        backgroundColor, titleTextColor)
                    toggleWidgetPreviewTheme(binding, backgroundColor, titleTextColor)
                }
                R.id.radio_button_light -> {
                    val backgroundColor = ContextCompat.getColor(this, R.color.light_mode_background)
                    val titleTextColor = Color.BLACK
                    ListSharedPrefsUtil.saveSemesterProgressWidgetTheme(this, appWidgetId,
                        backgroundColor, titleTextColor)
                    toggleWidgetPreviewTheme(binding, backgroundColor, titleTextColor)
                }
            }
        }
    }

    private fun toggleWidgetPreviewTheme(
        binding: SemesterProgressConfigurationActivityBinding,
        backgroundColor: Int,
        titleTextColor: Int) {
        val widgetPreviewSmall = binding.widgetPreviewSmall
        val widgetPreviewLarge = binding.widgetPreviewLarge

        val smallPreviewBackground = widgetPreviewSmall.findViewById<ImageView>(R.id.widget_background)
        val largePreviewBackground = widgetPreviewLarge.findViewById<ImageView>(R.id.widget_background)
        val smallViewDrawable = smallPreviewBackground.drawable
        val largeDrawable = largePreviewBackground.drawable
        val titleText = widgetPreviewLarge.findViewById<TextView>(R.id.semester_progress_title)

        if (smallViewDrawable is GradientDrawable) {
            smallViewDrawable.setColor(backgroundColor)
        }
        if (largeDrawable is GradientDrawable) {
            largeDrawable.setColor(backgroundColor)
        }

        smallPreviewBackground.setImageDrawable(smallViewDrawable)
        largePreviewBackground.setImageDrawable(largeDrawable)

        titleText.setTextColor(titleTextColor)
    }
}