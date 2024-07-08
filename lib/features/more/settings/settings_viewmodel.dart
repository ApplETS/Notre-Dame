// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';

class SettingsViewModel extends FutureViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Current locale
  String? _currentLocale;

  /// Current theme
  ThemeMode? _selectedTheme;

  ThemeMode? get selectedTheme => _selectedTheme;

  /// Set theme
  set selectedTheme(ThemeMode? value) {
    if (value != null) {
      _settingsManager.setThemeMode(value);
      _selectedTheme = value;
    }
  }

  String get currentLocale {
    if (_currentLocale == AppIntl.supportedLocales.first.languageCode) {
      return _appIntl.settings_english;
    } else if (_currentLocale == AppIntl.supportedLocales.last.languageCode) {
      return _appIntl.settings_french;
    } else {
      return "";
    }
  }

  /// Set Locale
  set currentLocale(String value) {
    _settingsManager.setLocale(value);
    _currentLocale = value;
  }

  SettingsViewModel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future futureToRun() async {
    setBusy(true);
    await _settingsManager.fetchLanguageAndThemeMode();
    _currentLocale = _settingsManager.locale?.languageCode;
    _selectedTheme = _settingsManager.themeMode;
    setBusy(false);
    return true;
  }
}
