// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// OTHERS
import 'package:notredame/locator.dart';

class SettingsViewModel extends FutureViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Current locale
  String _currentLocale;

  /// Current theme
  ThemeMode _selectedTheme;

  ThemeMode get selectedTheme => _selectedTheme;

  /// Set theme
  set selectedTheme(ThemeMode value) {
    _settingsManager.setThemeMode(value);
    _selectedTheme = value;
  }

  String get currentLocale {
    if (_currentLocale == AppIntl.supportedLocales.first.languageCode) {
      return _appIntl.settings_english;
    } else if (_currentLocale == AppIntl.supportedLocales.last.languageCode) {
      return _appIntl.settings_french;
    } else {
      return _appIntl.system_theme;
    }
  }

  /// Set Locale
  set currentLocale(String value) {
    _settingsManager.setLocale(value);
    _currentLocale = value;
  }

  SettingsViewModel({@required AppIntl intl}) : _appIntl = intl;

  @override
  Future futureToRun() async {
    setBusy(true);
    await _settingsManager.getString(PreferencesFlag.theme).then((value) =>
        _selectedTheme =
            ThemeMode.values.firstWhere((e) => e.toString() == value));
    await _settingsManager
        .getString(PreferencesFlag.locale)
        .then((value) => _currentLocale = value);
    setBusy(false);
    return true;
  }
}
