// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/locator.dart';

class SettingsViewModel extends FutureViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Current locale
  String _currentLocale;

  /// Current theme
  String _selectedTheme;

  String get selectedTheme {
    if (_selectedTheme == ThemeMode.light.toString()) {
      return AppIntl.current.light_theme;
    } else if (_selectedTheme == ThemeMode.dark.toString()) {
      return AppIntl.current.dark_theme;
    } else {
      return AppIntl.current.system_theme;
    }
  }

  /// Set theme
  set selectedTheme(String value) {
    _settingsManager.setThemeMode(value);
    _selectedTheme = value;
  }

  String get currentLocale {
    if (_currentLocale ==
        AppIntl.delegate.supportedLocales.first.languageCode) {
      return AppIntl.current.settings_english;
    } else {
      return AppIntl.current.settings_french;
    }
  }

  /// Set Locale
  set currentLocale(String value) {
    _settingsManager.setLocale(value);
    _currentLocale = value;
  }

  @override
  Future futureToRun() async {
    setBusy(true);
    await _settingsManager
        .getString(PreferencesFlag.theme)
        .then((value) => _selectedTheme = value);
    await _settingsManager
        .getString(PreferencesFlag.locale)
        .then((value) => _currentLocale = value);
    setBusy(false);
    return true;
  }
}
