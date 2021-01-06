import 'package:enum_to_string/enum_to_string.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleSettingsViewModel
    extends FutureViewModel<Map<PreferencesFlag, dynamic>> {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Current calendar format
  CalendarFormat _calendarFormat;
  CalendarFormat get calendarFormat => _calendarFormat;
  set calendarFormat(CalendarFormat format) {
    _settingsManager.setString(PreferencesFlag.scheduleSettingsCalendarFormat,
        EnumToString.convertToString(format));
    _calendarFormat = format;
  }

  /// List of possible calendar format.
  List<CalendarFormat> calendarFormatPossibles = [
    CalendarFormat.month,
    CalendarFormat.twoWeeks,
    CalendarFormat.week
  ];

  /// Current starting day of week
  StartingDayOfWeek _startingDayOfWeek;
  StartingDayOfWeek get startingDayOfWeek => _startingDayOfWeek;
  set startingDayOfWeek(StartingDayOfWeek day) {
    _settingsManager.setString(PreferencesFlag.scheduleSettingsStartWeekday,
        EnumToString.convertToString(day));
    _startingDayOfWeek = day;
  }

  /// List of possible days to set as start of the week
  List<StartingDayOfWeek> startingDayPossible = [
    StartingDayOfWeek.saturday,
    StartingDayOfWeek.sunday,
    StartingDayOfWeek.monday,
  ];

  bool showTodayBtn;

  @override
  Future<Map<PreferencesFlag, dynamic>> futureToRun() async {
    final settings = await _settingsManager.getScheduleSettings();

    _calendarFormat = settings[PreferencesFlag.scheduleSettingsCalendarFormat]
        as CalendarFormat;
    startingDayOfWeek = settings[PreferencesFlag.scheduleSettingsStartWeekday]
        as StartingDayOfWeek;
    showTodayBtn =
        settings[PreferencesFlag.scheduleSettingsShowTodayBtn] as bool;

    return settings;
  }
}
