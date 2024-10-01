package ca.etsmtl.applets.etsmobile

import android.content.Context
import android.content.res.Configuration
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import java.util.Locale

class Utilities {
    companion object{
        fun getLocalizedString(context: Context, stringResId: Int): String {
            val locale = when (getLangFromSharedPreferences(context)) {
                Constants.SHARED_PREFERENCES_LANG_EN -> Locale.ENGLISH
                Constants.SHARED_PREFERENCES_LANG_FR -> Locale.FRENCH
                else -> Locale.FRENCH
            }
            return getStringFromLocale(context, stringResId, locale)
        }

        private fun getStringFromLocale(context: Context, resourceId: Int, locale: Locale): String {
            val config = Configuration(context.resources.configuration)
            config.setLocale(locale)
            val localizedContext = context.createConfigurationContext(config)
            return localizedContext.resources.getString(resourceId)
        }

        fun getAppTheme(context: Context): String {
            val sharedPreferences = context.getSharedPreferences(Constants.SHARED_PREFERENCES_FILE, Context.MODE_PRIVATE)
            val theme = sharedPreferences.getString(Constants.SHARED_PREFERENCES_THEME_KEY, null)

            return if (theme == null || theme == Constants.SHARED_PREFERENCES_THEME_SYSTEM) {
                val currentNightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK

                when (currentNightMode) {
                    Configuration.UI_MODE_NIGHT_YES -> Constants.SHARED_PREFERENCES_THEME_DARK
                    Configuration.UI_MODE_NIGHT_NO -> Constants.SHARED_PREFERENCES_THEME_LIGHT
                    else -> Constants.SHARED_PREFERENCES_THEME_DARK
                }
            } else {
                theme
            }
        }

        fun getLangFromSharedPreferences(context: Context): String {
            val sharedPreferences = context.getSharedPreferences(Constants.SHARED_PREFERENCES_FILE, Context.MODE_PRIVATE)
            return sharedPreferences.getString(Constants.SHARED_PREFERENCES_LANG_KEY, Constants.SHARED_PREFERENCES_LANG_FR).toString()
        }

        fun isInternetAvailable(context: Context): Boolean {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork ?: return false
                val activeNetwork = connectivityManager.getNetworkCapabilities(network) ?: return false
                return when {
                    activeNetwork.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> true
                    activeNetwork.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> true
                    else -> false
                }
            } else {
                @Suppress("DEPRECATION")
                val networkInfo = connectivityManager.activeNetworkInfo ?: return false
                @Suppress("DEPRECATION")
                return networkInfo.isConnected
            }
        }
    }
}