// FLUTTER / DART / THIRD-PARTIES
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

  /// Possible theme choices
  final light = 'light';
  final dark = 'dark';
  final system = 'system';

  String get selectedTheme {
    return _selectedTheme == light
        ? AppIntl.current.light_theme
        : _selectedTheme == dark
            ? AppIntl.current.dark_theme
            : AppIntl.current.system_theme;
  }

  /// Set theme
  set selectedTheme(String value) {
    if (value == light) {
      _settingsManager.setLightMode();
    } else if (value == dark) {
      _settingsManager.setDarkMode();
    } else {
      _settingsManager.setSystemMode();
    }
    _selectedTheme = value;
  }

  String get currentLocale => _currentLocale ?? AppIntl.current.system_theme;

  /// Set Locale
  set currentLocale(String value) {
    if (value == AppIntl.current.settings_english) {
      _settingsManager.setEnglish();
    } else {
      _settingsManager.setFrench();
    }
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
