// Package imports:
import 'package:collection/collection.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';

class ScheduleSettingsViewModel extends FutureViewModel<Map<PreferencesFlag, dynamic>> {
  ScheduleSettingsViewModel({required ScheduleController controller}) : _controller = controller;

  /// Allows to update other views
  final ScheduleController _controller;

  /// Manage the settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  // Access the course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Current calendar format
  CalendarTimeFormat? _calendarFormat;

  CalendarTimeFormat? get calendarFormat => _calendarFormat;

  set calendarFormat(CalendarTimeFormat? format) {
    setBusy(true);
    _settingsManager.setString(PreferencesFlag.scheduleCalendarFormat, format?.name);
    _calendarFormat = format;
    _controller.settingsUpdated();
    setBusy(false);
  }

  /// Display the button to return to today
  bool _showTodayBtn = true;

  bool get showTodayBtn => _showTodayBtn;

  set showTodayBtn(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleShowTodayBtn, newValue);
    _showTodayBtn = newValue;
    _controller.settingsUpdated();
    setBusy(false);
  }

  bool _toggleCalendarView = false;

  bool get toggleCalendarView => _toggleCalendarView;

  set toggleCalendarView(bool newValue) {
    setBusy(true);
    _settingsManager.setBool(PreferencesFlag.scheduleListView, newValue);
    _toggleCalendarView = newValue;
    _controller.settingsUpdated();
    setBusy(false);
  }

  /// The schedule activities which needs to be shown (group A or B) grouped as courses
  final Map<String, List<ScheduleActivity>> _scheduleActivitiesByCourse = {};

  Map<String, List<ScheduleActivity>> get scheduleActivitiesByCourse => _scheduleActivitiesByCourse;

  final Map<String, ScheduleActivity> _selectedScheduleActivity = {};

  Map<String, ScheduleActivity> get selectedScheduleActivity => _selectedScheduleActivity;

  /// This function is used to save the state of the selected course settings
  /// for a given course that has different laboratory group
  Future selectScheduleActivity(String courseAcronym, ScheduleActivity? scheduleActivityToSave) async {
    setBusy(true);
    if (scheduleActivityToSave == null) {
      await _settingsManager.setDynamicString(PreferencesFlag.scheduleLaboratoryGroup, courseAcronym, null);
      _selectedScheduleActivity.remove(courseAcronym);
    } else {
      await _settingsManager.setDynamicString(
        PreferencesFlag.scheduleLaboratoryGroup,
        courseAcronym,
        scheduleActivityToSave.activityCode,
      );
      _selectedScheduleActivity[courseAcronym] = scheduleActivityToSave;
    }
    _controller.settingsUpdated();
    setBusy(false);
  }

  @override
  Future<Map<PreferencesFlag, dynamic>> futureToRun() async {
    setBusy(true);
    final settings = await _settingsManager.getScheduleSettings();

    _calendarFormat = settings[PreferencesFlag.scheduleCalendarFormat] as CalendarTimeFormat;
    _showTodayBtn = settings[PreferencesFlag.scheduleShowTodayBtn] as bool;
    _toggleCalendarView = settings[PreferencesFlag.scheduleListView] as bool;

    _scheduleActivitiesByCourse.clear();
    final schedulesActivities = await _courseRepository.getScheduleActivities();
    for (final activity in schedulesActivities) {
      if (activity.activityCode == ActivityCode.labGroupA || activity.activityCode == ActivityCode.labGroupB) {
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
        PreferencesFlag.scheduleLaboratoryGroup,
        courseKey,
      );
      final scheduleActivity = _scheduleActivitiesByCourse[courseKey]?.firstWhereOrNull(
        (element) => element.activityCode == scheduleActivityCode,
      );
      if (scheduleActivity != null) {
        _selectedScheduleActivity[courseKey] = scheduleActivity;
      }
    }

    setBusy(false);
    return settings;
  }
}
