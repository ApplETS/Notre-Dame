// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

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
    _settingsManager.setString(PreferencesFlag.scheduleCalendarFormat,
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

  bool getCalendarViewEnabled() {
    return _settingsManager.getCalendarViewEnabled();
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
      String courseAcronym, ScheduleActivity scheduleActivityToSave) async {
    setBusy(true);
    if (scheduleActivityToSave == null) {
      await _settingsManager.setDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseAcronym, null);
    } else {
      await _settingsManager.setDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup,
          courseAcronym,
          scheduleActivityToSave.activityCode);
    }
    _selectedScheduleActivity[courseAcronym] = scheduleActivityToSave;
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
          if (!_scheduleActivitiesByCourse[activity.courseAcronym]
              .contains(activity)) {
            _scheduleActivitiesByCourse[activity.courseAcronym].add(activity);
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
          .firstWhere((element) => element.activityCode == scheduleActivityCode,
              orElse: () => null);
      if (scheduleActivity != null) {
        _selectedScheduleActivity[courseKey] = scheduleActivity;
      }
    }

    setBusy(false);
    return settings;
  }
}
