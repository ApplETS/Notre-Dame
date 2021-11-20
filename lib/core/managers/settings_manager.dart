// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    notifyListeners();
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
    // When the locale isn't defined, set a default locale
    if (_locale == null) {
      final locale = Locale(Intl.systemLocale.split('_')[0]);
      if (AppIntl.supportedLocales.contains(locale)) {
        _locale = locale;
      } else {
        _locale = const Locale('fr');
      }
    }
    return _locale;
  }

  /// Get Dashboard
  Future<Map<PreferencesFlag, int>> getDashboard() async {
    final Map<PreferencesFlag, int> dashboard = {};

    final aboutUsIndex =
        await _preferencesService.getInt(PreferencesFlag.aboutUsCard) ??
            getDefaultCardIndex(PreferencesFlag.aboutUsCard);

    dashboard.putIfAbsent(PreferencesFlag.aboutUsCard, () => aboutUsIndex);

    final scheduleCardIndex =
        await _preferencesService.getInt(PreferencesFlag.scheduleCard) ??
            getDefaultCardIndex(PreferencesFlag.scheduleCard);

    dashboard.putIfAbsent(
        PreferencesFlag.scheduleCard, () => scheduleCardIndex);

    final progressBarCardIndex =
        await _preferencesService.getInt(PreferencesFlag.progressBarCard) ??
            getDefaultCardIndex(PreferencesFlag.progressBarCard);

    dashboard.putIfAbsent(
        PreferencesFlag.progressBarCard, () => progressBarCardIndex);

    final gradesCardIndex =
        await _preferencesService.getInt(PreferencesFlag.gradesCard) ??
            getDefaultCardIndex(PreferencesFlag.gradesCard);

    dashboard.putIfAbsent(PreferencesFlag.gradesCard, () => gradesCardIndex);

    _logger.i("$tag - getDashboard - Dashboard loaded: $dashboard");

    return dashboard;
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
    _preferencesService.setString(PreferencesFlag.locale, _locale.languageCode);
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

    final showWeekEventsBtn = await _preferencesService
            .getBool(PreferencesFlag.scheduleSettingsShowWeekEvents) ??
        true;
    settings.putIfAbsent(PreferencesFlag.scheduleSettingsShowWeekEvents,
        () => showWeekEventsBtn);

    _logger.i("$tag - getScheduleSettings - Settings loaded: $settings");

    return settings;
  }

  /// Add/update the value of [flag]
  Future<bool> setString(PreferencesFlag flag, String value) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", value);

    if (value == null) {
      return _preferencesService.removePreferencesFlag(flag);
    }
    return _preferencesService.setString(flag, value);
  }

  /// Add/update the value of [flag]
  Future<bool> setDynamicString(
      DynamicPreferencesFlag flag, String value) async {
    // Log the event
    _analyticsService.logEvent("${tag}_${flag.toString()}", value);

    if (value == null) {
      return _preferencesService.removeDynamicPreferencesFlag(flag);
    }

    return _preferencesService.setDynamicString(flag, value);
  }

  /// Add/update the value of [flag]
  Future<bool> setInt(PreferencesFlag flag, int value) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", value.toString());
    return _preferencesService.setInt(flag, value);
  }

  /// Get the value of [flag]
  Future<String> getString(PreferencesFlag flag) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", 'getString');
    return _preferencesService.getString(flag);
  }

  /// Get the value of [flag]
  Future<String> getDynamicString(DynamicPreferencesFlag flag) async {
    // Log the event
    _analyticsService.logEvent("${tag}_${flag.toString()}", 'getString');
    return _preferencesService.getDynamicString(flag);
  }

  /// Add/update the value of [flag]
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(PreferencesFlag flag, bool value) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", value.toString());
    return _preferencesService.setBool(flag, value: value);
  }

  /// Get the value of [flag]
  Future<bool> getBool(PreferencesFlag flag) async {
    // Log the event
    _analyticsService.logEvent(
        "${tag}_${EnumToString.convertToString(flag)}", 'getBool');
    return _preferencesService.getBool(flag);
  }

  /// Get the default index of each card
  int getDefaultCardIndex(PreferencesFlag flag) =>
      flag.index - PreferencesFlag.aboutUsCard.index;
}
