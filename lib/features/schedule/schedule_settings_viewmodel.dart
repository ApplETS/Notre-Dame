// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/locator.dart';

class ScheduleSettingsViewModel
    extends FutureViewModel<Map<PreferencesFlag, dynamic>> {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  // Access the course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Current calendar format
  CalendarFormat? _calendarFormat;

  CalendarFormat? get calendarFormat => _calendarFormat;

  set calendarFormat(CalendarFormat? format) {
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleCalendarFormat,
        EnumToString.convertToString(format));
    _calendarFormat = format;
    setBusy(false);
  }

  /// List of possible calendar format for the list view.
  List<CalendarFormat> formatPossibleListView = [
    CalendarFormat.month,
    CalendarFormat.twoWeeks,
    CalendarFormat.week
  ];

  /// List of possible calendar format for the list view.
  List<CalendarFormat> formatPossibleCalendarView = [
    CalendarFormat.month,
    CalendarFormat.week,
    CalendarFormat.day
  ];

  /// Current starting day of week
  StartingDayOfWeek? _startingDayOfWeek;

  StartingDayOfWeek? get startingDayOfWeek => _startingDayOfWeek;

  set startingDayOfWeek(StartingDayOfWeek? day) {
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleStartWeekday,
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

  /// Current weekend day shown
  WeekDays? _otherDayOfWeek;

  WeekDays? get otherDayOfWeek => _otherDayOfWeek;

  set otherDayOfWeek(WeekDays? day) {
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleOtherWeekday,
        EnumToString.convertToString(day));
    _otherDayOfWeek = day;
    setBusy(false);
  }

  /// List of possible days to show in the calendar view
  List<WeekDays> otherDayPossible = [
    WeekDays.saturday,
    WeekDays.sunday,
  ];

  bool _showWeekendDays = false;

  bool get showWeekendDays => _showWeekendDays;

  set showWeekendDays(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleShowWeekendDays, newValue);
    _showWeekendDays = newValue;
    setBusy(false);
  }

  bool _showTodayBtn = true;

  bool get showTodayBtn => _showTodayBtn;

  set showTodayBtn(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleShowTodayBtn, newValue);
    _showTodayBtn = newValue;
    setBusy(false);
  }

  bool _toggleCalendarView = true;

  bool get toggleCalendarView => _toggleCalendarView;

  set toggleCalendarView(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleListView, newValue);
    _toggleCalendarView = newValue;
    setBusy(false);
  }

  bool _showWeekEvents = false;

  bool get showWeekEvents => _showWeekEvents;

  set showWeekEvents(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleShowWeekEvents, newValue);
    _showWeekEvents = newValue;
    setBusy(false);
  }

  /// The schedule activities which needs to be shown (group A or B) grouped as courses
  final Map<String, List<ScheduleActivity>> _scheduleActivitiesByCourse = {};

  Map<String, List<ScheduleActivity>> get scheduleActivitiesByCourse =>
      _scheduleActivitiesByCourse;

  final Map<String, ScheduleActivity> _selectedScheduleActivity = {};

  Map<String, ScheduleActivity> get selectedScheduleActivity =>
      _selectedScheduleActivity;

  /// This function is used to save the state of the selected course settings
  /// for a given course that has different laboratory group
  Future selectScheduleActivity(
      String courseAcronym, ScheduleActivity? scheduleActivityToSave) async {
    setBusy(true);
    if (scheduleActivityToSave == null) {
      await _settingsManager.setDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseAcronym, null);
    } else {
      await _settingsManager.setDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup,
          courseAcronym,
          scheduleActivityToSave.activityCode);
      _selectedScheduleActivity[courseAcronym] = scheduleActivityToSave;
    }
    setBusy(false);
  }

  @override
  Future<Map<PreferencesFlag, dynamic>> futureToRun() async {
    setBusy(true);
    final settings = await _settingsManager.getScheduleSettings();

    _calendarFormat =
        settings[PreferencesFlag.scheduleCalendarFormat] as CalendarFormat;
    _startingDayOfWeek =
        settings[PreferencesFlag.scheduleStartWeekday] as StartingDayOfWeek;
    _showTodayBtn = settings[PreferencesFlag.scheduleShowTodayBtn] as bool;
    _toggleCalendarView = settings[PreferencesFlag.scheduleListView] as bool;
    _showWeekEvents = settings[PreferencesFlag.scheduleShowWeekEvents] as bool;

    _scheduleActivitiesByCourse.clear();
    final schedulesActivities = await _courseRepository.getScheduleActivities();
    for (final activity in schedulesActivities) {
      if (activity.activityCode == ActivityCode.labGroupA ||
          activity.activityCode == ActivityCode.labGroupB) {
        // Create the list with the new activity inside or add the activity to an existing group
        if (!_scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          _scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          // Add the activity to the course.
          final course = _scheduleActivitiesByCourse[activity.courseAcronym];
          if (course != null && !course.contains(activity)) {
            course.add(activity);
          }
        }
      }
    }
    // Check if there is only one activity for each map, remove the map
    _scheduleActivitiesByCourse.removeWhere((key, value) => value.length == 1);

    // Preselect the right schedule activity
    for (final courseKey in _scheduleActivitiesByCourse.keys) {
      final scheduleActivityCode = await _settingsManager.getDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseKey);
      final scheduleActivity = _scheduleActivitiesByCourse[courseKey]
          ?.firstWhereOrNull(
              (element) => element.activityCode == scheduleActivityCode);
      if (scheduleActivity != null) {
        _selectedScheduleActivity[courseKey] = scheduleActivity;
      }
    }

    setBusy(false);
    return settings;
  }
}
