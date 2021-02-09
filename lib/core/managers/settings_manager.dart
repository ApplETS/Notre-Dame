// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/generated/l10n.dart';

class SettingsManager with ChangeNotifier {
  static const String tag = "SettingsManager";

  final Logger _logger = locator<Logger>();

  /// Use to get the value associated to each settings key
  final PreferencesService _preferencesService = locator<PreferencesService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// current ThemeMode
  ThemeMode _themeMode;

  /// current Locale
  Locale _locale;

  /// Get ThemeMode
  ThemeMode get themeMode {
    _preferencesService.getString(PreferencesFlag.theme).then((value) {
      final theme = value ?? 'system';
      if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
    return _themeMode;
  }

  /// Get Locale
  Locale get locale {
    _preferencesService.getString(PreferencesFlag.locale).then((value) {
      if (value == AppIntl.current.settings_french) {
        _locale = const Locale('fr');
      } else if (value == AppIntl.current.settings_english) {
        _locale = const Locale('en');
      } else {
        _locale = null;
      }
    });
    return _locale;
  }

  /// Set ThemeMode to ThemeMode.dark
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    _preferencesService.setString(PreferencesFlag.theme, 'dark');
    notifyListeners();
  }

  /// Set ThemeMode to ThemeMode.light
  void setLightMode() {
    _themeMode = ThemeMode.light;
    _preferencesService.setString(PreferencesFlag.theme, 'light');
    notifyListeners();
  }

  /// Set ThemeMode to ThemeMode.system
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    _preferencesService.setString(PreferencesFlag.theme, 'system');
    notifyListeners();
  }

  /// Set Locale to french
  void setFrench() {
    _preferencesService.setString(
        PreferencesFlag.locale, AppIntl.current.settings_french);
    _locale = const Locale('fr');
    notifyListeners();
  }

  /// Set Locale to english
  void setEnglish() {
    _preferencesService.setString(
        PreferencesFlag.locale, AppIntl.current.settings_english);
    _locale = const Locale('en');
    notifyListeners();
  }

  /// Get the settings of the schedule, these are loaded from the user preferences.
  Future<Map<PreferencesFlag, dynamic>> getScheduleSettings() async {
    final Map<PreferencesFlag, dynamic> settings = {};

    final calendarFormat = EnumToString.fromString(
            CalendarFormat.values,
            await _preferencesService
                .getString(PreferencesFlag.scheduleSettingsCalendarFormat)) ??
        CalendarFormat.week;
    settings.putIfAbsent(
        PreferencesFlag.scheduleSettingsCalendarFormat, () => calendarFormat);

    final startingWeekDay = EnumToString.fromString(
            StartingDayOfWeek.values,
            await _preferencesService
                .getString(PreferencesFlag.scheduleSettingsStartWeekday)) ??
        StartingDayOfWeek.monday;
    settings.putIfAbsent(
        PreferencesFlag.scheduleSettingsStartWeekday, () => startingWeekDay);

    final showTodayBtn = await _preferencesService
            .getBool(PreferencesFlag.scheduleSettingsShowTodayBtn) ??
        true;
    settings.putIfAbsent(
        PreferencesFlag.scheduleSettingsShowTodayBtn, () => showTodayBtn);

    _logger.i("$tag - getScheduleSettings - Settings loaded: $settings");

    return settings;
  }

  /// Add/update the value of [flag]
  Future<bool> setString(PreferencesFlag flag, String value) async {
    // Log the event
    _analyticsService.logEvent(
        "$tag-${EnumToString.convertToString(flag)}", value);
    return _preferencesService.setString(flag, value);
  }

  /// Get the value of [flag]
  Future<String> getString(PreferencesFlag flag) async {
    // Log the event
    _analyticsService.logEvent(
        "$tag-${EnumToString.convertToString(flag)}", 'getString');
    return _preferencesService.getString(flag);
  }

  /// Add/update the value of [flag]
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(PreferencesFlag flag, bool value) async {
    // Log the event
    _analyticsService.logEvent(
        "$tag-${EnumToString.convertToString(flag)}", value.toString());
    return _preferencesService.setBool(flag, value: value);
  }
}
