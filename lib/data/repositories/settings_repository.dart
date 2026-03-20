// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

PreferencesService get _preferencesService => locator<PreferencesService>();

class SettingsRepository with ChangeNotifier {
  final DashboardSettings _dashboardSettings = DashboardSettings();

  DashboardSettings get dashboard => _dashboardSettings;

  final ScheduleSettings _scheduleSettings = ScheduleSettings();

  ScheduleSettings get schedule => _scheduleSettings;

  final RatingSettings _ratingSettings = RatingSettings();

  RatingSettings get rating => _ratingSettings;

  /// Get current time
  DateTime get dateTimeNow => DateTime.now();

  Locale get locale {
    String? languageCode = _preferencesService.getString(PreferencesFlag.locale);
    return AppIntl.supportedLocales.firstWhereOrNull((e) => e.languageCode == languageCode) ?? const Locale('fr');
  }

  set locale(Locale? value) {
    Locale? locale = AppIntl.supportedLocales.firstWhereOrNull((e) => e == value);

    _preferencesService.setString(PreferencesFlag.locale, locale?.languageCode);
    notifyListeners();
  }

  bool get isLocaleDefined => _preferencesService.getString(PreferencesFlag.locale) != null;

  ThemeMode get themeMode {
    String? themeString = _preferencesService.getString(PreferencesFlag.theme);
    return ThemeMode.values.firstWhereOrNull((e) => e.toString() == themeString) ?? ThemeMode.system;
  }

  set themeMode(ThemeMode? value) {
    _preferencesService.setString(PreferencesFlag.theme, value.toString());
    notifyListeners();
  }

  bool get isLoggedIn => _preferencesService.getBool(PreferencesFlag.isLoggedIn) ?? false;

  set isLoggedIn(bool value) => _preferencesService.setBool(PreferencesFlag.isLoggedIn, value);

  DateTime? get replacedDaysCacheExpiration {
    String? dateAsString = _preferencesService.getString(PreferencesFlag.replacedDaysCacheExpiration);

    if (dateAsString != null) {
      return DateTime.parse(dateAsString);
    }

    return null;
  }

  set replacedDaysCacheExpiration(DateTime value) =>
      _preferencesService.setString(PreferencesFlag.replacedDaysCacheExpiration, value.toIso8601String());
}

class DashboardSettings {
  bool get displayScheduleAsList => _preferencesService.getBool(PreferencesFlag.dashboardScheduleList) ?? false;

  set displayScheduleAsList(bool value) => _preferencesService.setBool(PreferencesFlag.dashboardScheduleList, value);

  bool get displayProgressBarAltMode =>
      _preferencesService.getBool(PreferencesFlag.dashboardProgressBarAltMode) ?? false;

  set displayProgressBarAltMode(bool value) =>
      _preferencesService.setBool(PreferencesFlag.dashboardProgressBarAltMode, value);
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

  String? getLaboratoryGroup(String courseAcronym) =>
      _preferencesService.getDynamicString(PreferencesFlag.scheduleLaboratoryGroup, courseAcronym);

  Future<void> setLaboratoryGroup(String courseAcronym, String? activityCode) async =>
      await _preferencesService.setDynamicString(PreferencesFlag.scheduleLaboratoryGroup, courseAcronym, activityCode);
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
