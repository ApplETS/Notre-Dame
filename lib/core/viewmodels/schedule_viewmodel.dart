// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/discovery_ids.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

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
  final Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Day currently selected
  DateTime selectedDate;

  /// Day currently focused on
  ValueNotifier<DateTime> focusedDate;

  /// The currently selected CalendarFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarFormat calendarFormat = CalendarFormat.week;

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
        }).whenComplete(() {
          setBusyForObject(isLoadingEvents, false);
        });
        return value;
      });

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
    setBusy(false);
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

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discoverySchedule) ==
        null) {
      final List<String> ids =
          findDiscoveriesByGroupName(context, DiscoveryGroupIds.pageSchedule)
              .map((e) => e.featureId)
              .toList();

      Future.delayed(const Duration(milliseconds: 700),
          () => FeatureDiscovery.discoverFeatures(context, ids));

      _settingsManager.setString(PreferencesFlag.discoverySchedule, 'true');
    }
  }
}
