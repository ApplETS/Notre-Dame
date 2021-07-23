// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:notredame/core/constants/activity_code.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/schedule_activity.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// OTHER
import 'package:notredame/locator.dart';

class ScheduleSettingsViewModel
    extends FutureViewModel<Map<PreferencesFlag, dynamic>> {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();
  // Access the course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Current calendar format
  CalendarFormat _calendarFormat;

  CalendarFormat get calendarFormat => _calendarFormat;

  /// The schedule activities which needs to be shown (group A or B) grouped as courses
  Map<String, ScheduleActivity> _scheduleActivitiesByCourse;

  Map<String, ScheduleActivity> get scheduleActivitiesByCourse =>
      _scheduleActivitiesByCourse;

  set calendarFormat(CalendarFormat format) {
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleSettingsCalendarFormat,
        EnumToString.convertToString(format));
    _calendarFormat = format;
    setBusy(false);
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
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleSettingsStartWeekday,
        EnumToString.convertToString(day));
    _startingDayOfWeek = day;
    setBusy(false);
  }

  /// List of possible days to set as start of the week
  List<StartingDayOfWeek> startingDayPossible = [
    StartingDayOfWeek.saturday,
    StartingDayOfWeek.sunday,
    StartingDayOfWeek.monday,
  ];

  bool _showTodayBtn = true;

  bool get showTodayBtn => _showTodayBtn;

  set showTodayBtn(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(
        PreferencesFlag.scheduleSettingsShowTodayBtn, newValue);
    _showTodayBtn = newValue;
    setBusy(false);
  }

  @override
  Future<Map<PreferencesFlag, dynamic>> futureToRun() async {
    setBusy(true);
    final settings = await _settingsManager.getScheduleSettings();

    _calendarFormat = settings[PreferencesFlag.scheduleSettingsCalendarFormat]
        as CalendarFormat;
    _startingDayOfWeek = settings[PreferencesFlag.scheduleSettingsStartWeekday]
        as StartingDayOfWeek;
    _showTodayBtn =
        settings[PreferencesFlag.scheduleSettingsShowTodayBtn] as bool;

    final schedulesActivities = await _courseRepository.getScheduleActivities();
    for (final activity in schedulesActivities) {
      if (activity.activityCode == ActivityType.laboratoryGroupA ||
          activity.activityCode == ActivityType.laboratoryGroupB) {
        _scheduleActivitiesByCourse.putIfAbsent(
            activity.courseAcronym, () => activity);
      }
    }
    setBusy(false);
    return settings;
  }
}
