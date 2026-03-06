// Flutter imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class SettingsRepository with ChangeNotifier {
  static const String tag = "SettingsManager";

  final PreferencesService _preferencesService = locator<PreferencesService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// current ThemeMode
  ThemeMode? _themeMode;

  /// current Locale
  Locale? _locale;

  /// Get current time
  DateTime get dateTimeNow => DateTime.now();

  /// reset Locale and Theme when logout
  void resetLanguageAndThemeMode() {
    _locale = null;
    _themeMode = null;
    notifyListeners();
  }

  Locale get locale {
    _locale = AppIntl.supportedLocales.firstWhereOrNull(
      (e) => e.toString() == _preferencesService.getString(PreferencesFlag.locale),
    );

    // When the locale isn't defined, set a default locale
    if (_locale == null) {
      final locale = Locale(Intl.systemLocale.split('_')[0]);
      if (AppIntl.supportedLocales.contains(locale)) {
        _locale = locale;
      }
    }

    _locale ??= const Locale('fr');
    return _locale!;
  }

  set locale(Locale value) {
    _locale = AppIntl.supportedLocales.firstWhereOrNull((e) => e == value);

    _analyticsService.logEvent("${tag}_${PreferencesFlag.locale.name}", _locale?.languageCode ?? 'Not found');

    if (_locale != null) {
      _preferencesService.setString(PreferencesFlag.locale, _locale!.languageCode);
      _locale = Locale(_locale!.languageCode);
      notifyListeners();
    }
  }

  ThemeMode get themeMode {
    _themeMode = ThemeMode.values.firstWhereOrNull(
          (e) => e.toString() == _preferencesService.getString(PreferencesFlag.theme),
    );

    _themeMode ??= ThemeMode.system;

    return _themeMode!;
  }

  set themeMode(ThemeMode value) {
    _preferencesService.setString(PreferencesFlag.theme, value.toString());

    _analyticsService.logEvent("${tag}_${PreferencesFlag.theme.name}", value.name);
    _themeMode = value;
    notifyListeners();
  }

  CalendarTimeFormat get calendarFormat {
    final calendarFormat = _preferencesService.getString(PreferencesFlag.scheduleCalendarFormat) ?? CalendarTimeFormat.week.name;
    return CalendarTimeFormat.values.firstWhere((e) => e.name == calendarFormat);
  }

  set calendarFormat(CalendarTimeFormat format) => setString(PreferencesFlag.scheduleCalendarFormat, format.name);

  bool get sheduleListView => _preferencesService.getBool(PreferencesFlag.scheduleListView) ?? false;

  bool get showTodayButton => _preferencesService.getBool(PreferencesFlag.scheduleShowTodayBtn) ?? true;

  /// Add/update the value of [flag]
  Future<bool> setString(PreferencesFlag flag, String? value) async {
    // Log the event
    _analyticsService.logEvent("${tag}_${flag.name}", value.toString());

    if (value == null) {
      return _preferencesService.removePreferencesFlag(flag);
    }
    return _preferencesService.setString(flag, value);
  }

  /// Add/update the value of [flag]
  Future<bool> setDynamicString(PreferencesFlag flag, String key, String? value) async {
    if (value == null) {
      return _preferencesService.removeDynamicPreferencesFlag(flag, key);
    }

    // Log the event
    _analyticsService.logEvent("${tag}_$flag", value);

    return _preferencesService.setDynamicString(flag, key, value);
  }

  /// Get the value of [flag]
  String? getDynamicString(PreferencesFlag flag, String key) {
    // Log the event
    _analyticsService.logEvent("${tag}_$flag", 'getString');
    return _preferencesService.getDynamicString(flag, key);
  }

  /// Add/update the value of [flag]
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(PreferencesFlag flag, bool value) async {
    // Log the event
    _analyticsService.logEvent("${tag}_${flag.name}", value.toString());
    return _preferencesService.setBool(flag, value: value);
  }

  /// Get the value of [flag]
  bool? getBool(PreferencesFlag flag) {
    // Log the event
    _analyticsService.logEvent("${tag}_${flag.name}", 'getBool');
    return _preferencesService.getBool(flag);
  }
}
