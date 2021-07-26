// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/activity_code.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/schedule_activity.dart';

// SERVICE
import 'package:notredame/core/services/networking_service.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';

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
  final Map<DateTime, List<CourseActivity>> _coursesActivities = {};

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
  /// (Exemple: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// Get current locale
  Locale get locale => _settingsManager.locale;

  /// Verify if user has an active internet connection
  final NetworkingService _networkingService = locator<NetworkingService>();

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
            Utils.showNoConnectionToast(_networkingService, _appIntl);
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
          DynamicPreferencesFlag(
              groupAssociationFlag:
                  PreferencesFlag.scheduleSettingsLaboratoryGroup,
              uniqueKey: courseAcronym));
      final scheduleActivityToSet = scheduleActivitiesByCourse[courseAcronym]
          .firstWhere((element) => element.activityCode == activityCodeToUse,
              orElse: () => null);
      settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.name;
    }
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    if (_coursesActivities.isEmpty) {
      // Build the map
      for (final CourseActivity course in _courseRepository.coursesActivities) {
        final DateTime dateOnly = course.startDateTime.subtract(Duration(
            hours: course.startDateTime.hour,
            minutes: course.startDateTime.minute));
        _coursesActivities.update(dateOnly, (value) {
          value.add(course);

          return value;
        }, ifAbsent: () => [course]);
      }

      _coursesActivities.updateAll((key, value) {
        value.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        return value;
      });
    }
    return _coursesActivities;
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
}
