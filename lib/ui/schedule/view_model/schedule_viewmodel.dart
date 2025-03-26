// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';

class ScheduleViewModel extends FutureViewModel {
  /// Manage de settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// The currently selected CalendarTimeFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarTimeFormat calendarFormat = CalendarTimeFormat.week;

  bool get calendarViewSetting {
    if (busy(settings)) {
      return false;
    }
    return settings[PreferencesFlag.scheduleListView] as bool;
  }

  @override
  Future futureToRun() async {
    loadSettings();
  }

  Future loadSettings() async {
    setBusyForObject(settings, true);
    settings.clear();
    settings.addAll(await _settingsManager.getScheduleSettings());
    calendarFormat = settings[PreferencesFlag.scheduleCalendarFormat] as CalendarTimeFormat;
    setBusyForObject(settings, false);
  }
}
