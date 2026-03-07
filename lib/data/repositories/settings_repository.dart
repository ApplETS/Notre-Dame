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

final PreferencesService _preferencesService = locator<PreferencesService>();

class SettingsRepository with ChangeNotifier {
  static const String tag = "SettingsManager";

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final DashboardSettings _dashboardSettings = DashboardSettings();

  DashboardSettings get dashboard => _dashboardSettings;

  final ScheduleSettings _scheduleSettings = ScheduleSettings();

  ScheduleSettings get schedule => _scheduleSettings;

  final RatingSettings _ratingSettings = RatingSettings();

  RatingSettings get rating => _ratingSettings;

  /// Get current time
  DateTime get dateTimeNow => DateTime.now();

  Locale get locale {
    return AppIntl.supportedLocales.firstWhereOrNull(
          (e) => e.languageCode == _preferencesService.getString(PreferencesFlag.locale),
        ) ??
        const Locale('fr');
  }

  set locale(Locale? value) {
    Locale? locale = AppIntl.supportedLocales.firstWhereOrNull((e) => e == value);

    _preferencesService.setString(PreferencesFlag.locale, locale?.languageCode);
    notifyListeners();
  }

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhereOrNull(
          (e) => e.toString() == _preferencesService.getString(PreferencesFlag.theme),
        ) ??
        ThemeMode.system;
  }

  set themeMode(ThemeMode? value) {
    _preferencesService.setString(PreferencesFlag.theme, value.toString());
    notifyListeners();
  }

  bool get isLoggedIn => _preferencesService.getBool(PreferencesFlag.isLoggedIn) ?? false;

  set isLoggedIn(bool value) => _preferencesService.setBool(PreferencesFlag.isLoggedIn, value);

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
}

class DashboardSettings {
  bool get displayScheduleAsList => _preferencesService.getBool(PreferencesFlag.dashboardScheduleList) ?? false;

  set displayScheduleAsList(bool value) => _preferencesService.setBool(PreferencesFlag.dashboardScheduleList, value);
}

class ScheduleSettings {
  CalendarTimeFormat get calendarFormat {
    final calendarFormat =
        _preferencesService.getString(PreferencesFlag.scheduleCalendarFormat) ?? CalendarTimeFormat.week.name;
    return CalendarTimeFormat.values.firstWhere((e) => e.name == calendarFormat);
  }

  set calendarFormat(CalendarTimeFormat format) =>
      _preferencesService.setString(PreferencesFlag.scheduleCalendarFormat, format.name);

  bool get listView => _preferencesService.getBool(PreferencesFlag.scheduleListView) ?? false;

  set listView(bool value) => _preferencesService.setBool(PreferencesFlag.scheduleListView, value);

  bool get todayButton => _preferencesService.getBool(PreferencesFlag.scheduleShowTodayBtn) ?? true;

  set todayButton(bool value) => _preferencesService.setBool(PreferencesFlag.scheduleShowTodayBtn, value);
}

class RatingSettings {
  DateTime? get timer {
    String? dateAsString = _preferencesService.getString(PreferencesFlag.ratingTimer);

    if (dateAsString != null) {
      return DateTime.parse(dateAsString);
    }

    return null;
  }

  set timer(DateTime value) => _preferencesService.setString(PreferencesFlag.ratingTimer, value.toIso8601String());

  bool get hasBeenRequested => _preferencesService.getBool(PreferencesFlag.hasRatingBeenRequested) ?? false;

  set hasBeenRequested(bool value) => _preferencesService.setBool(PreferencesFlag.hasRatingBeenRequested, value);
}
