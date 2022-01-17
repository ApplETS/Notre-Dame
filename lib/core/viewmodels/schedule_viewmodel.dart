// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/activity_code.dart';
import 'package:notredame/core/constants/discovery_ids.dart';
// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/schedule_activity.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/preferences_flags.dart';

class ScheduleViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Day currently selected
  DateTime selectedDate;

  /// Day currently focused on
  ValueNotifier<DateTime> focusedDate;

  /// The currently selected CalendarFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarFormat calendarFormat = CalendarFormat.week;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// Get current locale
  Locale get locale => _settingsManager.locale;

  ScheduleViewModel({@required AppIntl intl, DateTime initialSelectedDate})
      : _appIntl = intl,
        selectedDate = initialSelectedDate ?? DateTime.now(),
        focusedDate = ValueNotifier(initialSelectedDate ?? DateTime.now());

  /// Activities for the day currently selected
  List<dynamic> get selectedDateEvents =>
      _coursesActivities[
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day)] ??
      [];

  bool isLoadingEvents = false;

  @override
  Future<List<CourseActivity>> futureToRun() =>
      _courseRepository.getCoursesActivities(fromCacheOnly: true).then((value) {
        setBusyForObject(isLoadingEvents, true);
        _courseRepository
            .getCoursesActivities()
            // ignore: return_type_invalid_for_catch_error
            .catchError(onError)
            .then((value) {
          if (value != null) {
            // Reload the list of activities
            coursesActivities;
          }
          _courseRepository
              .getScheduleActivities()
              // ignore: return_type_invalid_for_catch_error
              .catchError(onError)
              .then((value) async {
            await assignScheduleActivities(value);
          }).whenComplete(() {
            setBusyForObject(isLoadingEvents, false);
          });
        });
        return value;
      });

  Future assignScheduleActivities(
      List<ScheduleActivity> listOfSchedules) async {
    if (listOfSchedules == null ||
        listOfSchedules.isEmpty ||
        !listOfSchedules.any((element) =>
            element.activityCode == ActivityCode.labGroupA ||
            element.activityCode == ActivityCode.labGroupB)) return;

    setBusy(true);
    scheduleActivitiesByCourse.clear();
    for (final activity in listOfSchedules) {
      if (activity.activityCode == ActivityCode.labGroupA ||
          activity.activityCode == ActivityCode.labGroupB) {
        // Create the list with the new activity inside or add the activity to an existing group
        if (!scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          scheduleActivitiesByCourse[activity.courseAcronym].add(activity);
        }
      }
    }

    await loadSettingsScheduleActivities();
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future loadSettings() async {
    setBusy(true);
    settings.clear();
    settings.addAll(await _settingsManager.getScheduleSettings());
    calendarFormat = settings[PreferencesFlag.scheduleSettingsCalendarFormat]
        as CalendarFormat;

    await loadSettingsScheduleActivities();

    setBusy(false);
  }

  Future loadSettingsScheduleActivities() async {
    for (final courseAcronym in scheduleActivitiesByCourse.keys) {
      final String activityCodeToUse = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleSettingsLaboratoryGroup,
        courseAcronym);
      final scheduleActivityToSet = scheduleActivitiesByCourse[courseAcronym]
          .firstWhere((element) => element.activityCode == activityCodeToUse,
              orElse: () => null);
      if (scheduleActivityToSet != null) {
        settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.name;
      } else {
        // All group selected
        settingsScheduleActivities
            .removeWhere((key, value) => key == courseAcronym);
      }

      coursesActivities;
    }
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    _coursesActivities = {};

    // Build the map
    if (_courseRepository.coursesActivities != null) {
      for (final CourseActivity course in _courseRepository.coursesActivities) {
        final DateTime dateOnly = course.startDateTime.subtract(Duration(
            hours: course.startDateTime.hour,
            minutes: course.startDateTime.minute));

        if (!_coursesActivities.containsKey(dateOnly)) {
          _coursesActivities[dateOnly] = [];
        }

        _coursesActivities.update(dateOnly, (value) {
          final scheduleActivitiesContainsGroup = settingsScheduleActivities
              .containsKey(course.courseGroup.split("-").first);

          if (scheduleActivitiesContainsGroup) {
            if (scheduleActivityIsSelected(course)) {
              value.add(course);
            }
          } else {
            value.add(course);
          }

          return value;
        }, ifAbsent: () => [course]);
      }
    }

    _coursesActivities.updateAll((key, value) {
      value.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      return value;
    });

    return _coursesActivities;
  }

  bool scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityDescription != ActivityDescriptionName.labA &&
        course.activityDescription != ActivityDescriptionName.labB) {
      return true;
    }

    final activityNameSelected =
        settingsScheduleActivities[course.courseGroup.split("-").first];

    return activityNameSelected == course.activityDescription;
  }

  /// Get the activities for a specific [date], return empty if there is no activity for this [date]
  List<CourseActivity> coursesActivitiesFor(DateTime date) {
    // Populate the _coursesActivities
    if (_coursesActivities.isEmpty) {
      coursesActivities;
    }

    // Access the array using the same instance inside the map. This is only required
    // since the version 3.0.0 of table_calendar with the eventLoaders argument.
    DateTime dateInArray;
    return _coursesActivities.keys.any((element) {
      dateInArray = element;
      return isSameDay(element, date);
    })
        ? _coursesActivities[dateInArray]
        : [];
  }

  Future setCalendarFormat(CalendarFormat format) async {
    calendarFormat = format;
    settings[PreferencesFlag.scheduleSettingsCalendarFormat] = calendarFormat;
    _settingsManager.setString(PreferencesFlag.scheduleSettingsCalendarFormat,
        EnumToString.convertToString(calendarFormat));
  }

  Future<void> refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      await _courseRepository.getCoursesActivities();
      setBusyForObject(isLoadingEvents, false);
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    }
  }

  /// Start Discovery if needed.
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager _settingsManager = locator<SettingsManager>();

    if (await _settingsManager.getBool(PreferencesFlag.discoverySchedule) ==
        null) {
      final List<String> ids =
          findDiscoveriesByGroupName(context, DiscoveryGroupIds.pageSchedule)
              .map((e) => e.featureId)
              .toList();

      Future.delayed(const Duration(milliseconds: 700),
          () => FeatureDiscovery.discoverFeatures(context, ids));
    }
  }

  /// Mark the discovery of this view completed
  Future<bool> discoveryCompleted() async {
    await _settingsManager.setBool(PreferencesFlag.discoverySchedule, true);

    return true;
  }
}
