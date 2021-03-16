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
      if (value != null) {
        _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == value);
      }
    });
    return _themeMode;
  }

  /// reset Locale and Theme when logout
  void resetLanguageAndThemeMode() {
    _locale = null;
    _themeMode = null;
  }

  /// Get Locale and Theme to init app with
  Future<void> fetchLanguageAndThemeMode() async {
    final theme = await _preferencesService.getString(PreferencesFlag.theme);
    if (theme != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == theme);
    }
    final lang = await _preferencesService.getString(PreferencesFlag.locale);
    if (lang != null) {
      _locale =
          AppIntl.supportedLocales.firstWhere((e) => e.toString() == lang);
    }
  }

  /// Get Locale
  Locale get locale {
    _preferencesService.getString(PreferencesFlag.locale).then((value) {
      if (value != null) {
        _locale =
            AppIntl.supportedLocales.firstWhere((e) => e.toString() == value);
      }
    });
    if (_locale == null) {
      return null;
    }
    return Locale(_locale.languageCode);
  }

  /// Set ThemeMode
  void setThemeMode(ThemeMode value) {
    _preferencesService.setString(PreferencesFlag.theme, value.toString());
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(PreferencesFlag.theme)}",
        EnumToString.convertToString(value));
    _themeMode = value;
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
