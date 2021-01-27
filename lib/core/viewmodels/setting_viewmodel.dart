// FLUTTER / DART / THIRD-PARTIES
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import '../../locator.dart';

class SettingsViewModel extends FutureViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Current locale
  String _currentLocale;

  /// Current theme
  String _selectedTheme;

  String get selectedTheme => _selectedTheme ?? '';

  /// Set theme
  void setTheme(BuildContext context, String value) {
    if (value == 'Light') {
      AdaptiveTheme.of(context).setLight();
    } else if (value == 'Dark') {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setSystem();
    }
    _selectedTheme = value;
  }

  String get currentLocale => _currentLocale ?? '';

  set currentLocale(String value) {
    _settingsManager.setString(PreferencesFlag.locale, value);
    if (value == 'English') {
      AppIntl.load(const Locale('en'));
    } else {
      AppIntl.load(const Locale('fr'));
    }
    _currentLocale = value;
  }

  @override
  Future futureToRun() async {
    setBusy(true);
    await AdaptiveTheme.getThemeMode()
        .then((value) => _selectedTheme = value.name);
    await _settingsManager
        .getString(PreferencesFlag.locale)
        .then((value) => _currentLocale = value);
    setBusy(false);
    return true;
  }
}
