// Dart imports:
import 'dart:async';

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

class ScheduleSettingsViewModel extends FutureViewModel {
  ScheduleSettingsViewModel({required ScheduleController controller}) : _controller = controller;

  /// Allows to update other views
  final ScheduleController _controller;

  /// Manage the settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  // Access the course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  CalendarTimeFormat? get calendarFormat => _settingsManager.calendarFormat;

  set calendarFormat(CalendarTimeFormat format) {
    _settingsManager.calendarFormat = format;
    _controller.settingsUpdated();
  }

  bool get showTodayBtn => _settingsManager.showTodayButton;

  set showTodayBtn(bool newValue) {
    setBusy(true);
    _settingsManager.showTodayButton = newValue;
    _controller.settingsUpdated();
    setBusy(false);
  }

  bool get listViewFormat => _settingsManager.scheduleListView;

  set listViewFormat(bool newValue) {
    setBusy(true);
    _settingsManager.scheduleListView = newValue;
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
    setBusy(false);
    _controller.refreshEvents();
  }

  @override
  Future<void> futureToRun() async {
    setBusy(true);
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
      final scheduleActivityCode = _settingsManager.getDynamicString(
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
  }
}
