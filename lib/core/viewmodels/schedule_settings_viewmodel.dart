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

  /// The schedule activities which needs to be shown (group A or B) grouped as courses
  final Map<String, List<ScheduleActivity>> _scheduleActivitiesByCourse = {};

  Map<String, List<ScheduleActivity>> get scheduleActivitiesByCourse =>
      _scheduleActivitiesByCourse;

  ScheduleActivity _selectedScheduleActivity;

  ScheduleActivity get selectedScheduleActivity => _selectedScheduleActivity;

  /// This function is used to save the state of the selected course settings
  /// for a given course that has different laboratory group
  Future selectScheduleActivity(
      String courseAcronym, ScheduleActivity scheduleActivityToSave) async {
    setBusy(true);
    if (scheduleActivityToSave == null) {
      await _settingsManager.setDynamicString(
          DynamicPreferencesFlag(
              groupAssociationFlag:
                  PreferencesFlag.scheduleSettingsLaboratoryGroupCourse,
              specialKey: courseAcronym),
          null);
    } else {
      await _settingsManager.setDynamicString(
          DynamicPreferencesFlag(
              groupAssociationFlag:
                  PreferencesFlag.scheduleSettingsLaboratoryGroupCourse,
              specialKey: courseAcronym),
          scheduleActivityToSave.activityCode);
    }
    _selectedScheduleActivity = scheduleActivityToSave;
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
        // Create the list with the new activity inside or add the activity to an existing group
        if (!_scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          _scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          _scheduleActivitiesByCourse[activity.courseAcronym].add(activity);
        }
      }
    }
    setBusy(false);
    return settings;
  }
}
