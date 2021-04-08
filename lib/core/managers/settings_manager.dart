// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/locator.dart';

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
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == value);
    });
    return _themeMode;
  }

  /// Get Locale
  Locale get locale {
    _preferencesService.getString(PreferencesFlag.locale).then((value) {
      _locale =
          AppIntl.supportedLocales.firstWhere((e) => e.toString() == value);
    });
    if (_locale == null) {
      return null;
    }
    return Locale(_locale.languageCode);
  }

  /// Set ThemeMode
  void setThemeMode(String value) {
    _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == value);
    _preferencesService.setString(PreferencesFlag.theme, _themeMode.toString());
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(PreferencesFlag.theme)}",
        EnumToString.convertToString(_themeMode));
    notifyListeners();
  }

  /// Set Locale
  void setLocale(String value) {
    _locale = AppIntl.supportedLocales.firstWhere((e) => e.toString() == value);
    _preferencesService.setString(
        PreferencesFlag.locale, _locale.languageCode.toString());
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(PreferencesFlag.locale)}",
        _locale.languageCode);
    _locale = Locale(_locale.languageCode);
    notifyListeners();
  }

  /// Get the settings of the schedule, these are loaded from the user preferences.
  Future<Map<PreferencesFlag, dynamic>> getScheduleSettings() async {
    final Map<PreferencesFlag, dynamic> settings = {};

    final calendarFormat = await _preferencesService
        .getString(PreferencesFlag.scheduleSettingsCalendarFormat)
        .then((value) => value == null
            ? CalendarFormat.week
            : EnumToString.fromString(CalendarFormat.values, value));
    settings.putIfAbsent(
        PreferencesFlag.scheduleSettingsCalendarFormat, () => calendarFormat);

    final startingWeekDay = await _preferencesService
        .getString(PreferencesFlag.scheduleSettingsStartWeekday)
        .then((value) => value == null
            ? StartingDayOfWeek.monday
            : EnumToString.fromString(StartingDayOfWeek.values, value));
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
        "${tag}_${EnumToString.convertToString(flag)}", value);
    return _preferencesService.setString(flag, value);
  }

  /// Get the value of [flag]
  Future<String> getString(PreferencesFlag flag) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", 'getString');
    return _preferencesService.getString(flag);
  }

  /// Add/update the value of [flag]
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(PreferencesFlag flag, bool value) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", value.toString());
    return _preferencesService.setBool(flag, value: value);
  }
}
