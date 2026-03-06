// Flutter imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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

  /// Get current time
  DateTime get dateTimeNow => DateTime.now();
  
  Locale get locale {
    return AppIntl.supportedLocales.firstWhereOrNull((e) => e.languageCode == getString(PreferencesFlag.locale)) ??
        const Locale('fr');
  }

  set locale(Locale? value) {
    Locale? locale = AppIntl.supportedLocales.firstWhereOrNull((e) => e == value);

    setString(PreferencesFlag.locale, locale?.languageCode);
    notifyListeners();
  }

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhereOrNull(
          (e) => e.toString() == _preferencesService.getString(PreferencesFlag.theme),
        ) ??
        ThemeMode.system;
  }

  set themeMode(ThemeMode? value) {
    setString(PreferencesFlag.theme, value.toString());
    notifyListeners();
  }

  bool get dashboardScheduleList => getBool(PreferencesFlag.dashboardScheduleList) ?? false;

  set dashboardScheduleList(bool value) => setBool(PreferencesFlag.dashboardScheduleList, value);

  CalendarTimeFormat get calendarFormat {
    final calendarFormat =
        _preferencesService.getString(PreferencesFlag.scheduleCalendarFormat) ?? CalendarTimeFormat.week.name;
    return CalendarTimeFormat.values.firstWhere((e) => e.name == calendarFormat);
  }

  set calendarFormat(CalendarTimeFormat format) => setString(PreferencesFlag.scheduleCalendarFormat, format.name);

  bool get scheduleListView => _preferencesService.getBool(PreferencesFlag.scheduleListView) ?? false;

  set scheduleListView(bool value) => _preferencesService.setBool(PreferencesFlag.scheduleListView, value);

  bool get showTodayButton => _preferencesService.getBool(PreferencesFlag.scheduleShowTodayBtn) ?? true;

  set showTodayButton(bool value) => _preferencesService.setBool(PreferencesFlag.scheduleShowTodayBtn, value);

  /// Add/update the value of [flag]
  Future<bool> setString(PreferencesFlag flag, String? value) async {
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

    _analyticsService.logEvent("${tag}_$flag", value);
    return _preferencesService.setDynamicString(flag, key, value);
  }

  /// Get the value of [flag]
  String? getDynamicString(PreferencesFlag flag, String key) {
    _analyticsService.logEvent("${tag}_$flag", 'getString');
    return _preferencesService.getDynamicString(flag, key);
  }

  /// Add/update the value of [flag]
  Future<bool> setBool(PreferencesFlag flag, bool value) async {
    _analyticsService.logEvent("${tag}_${flag.name}", value.toString());
    return _preferencesService.setBool(flag, value);
  }

  /// Get the value of [flag]
  bool? getBool(PreferencesFlag flag) {
    _analyticsService.logEvent("${tag}_${flag.name}", 'getBool');
    return _preferencesService.getBool(flag);
  }

  /// Get the value of [flag]
  String? getString(PreferencesFlag flag) {
    _analyticsService.logEvent("${tag}_${flag.name}", 'getString');
    return _preferencesService.getString(flag);
  }
}
