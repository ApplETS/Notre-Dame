// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/locator.dart';

class SettingsManager {
  static const String tag = "SettingsManager";

  final Logger _logger = locator<Logger>();

  /// Use to get the value associated to each settings key
  final PreferencesService _preferencesService = locator<PreferencesService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

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
}
