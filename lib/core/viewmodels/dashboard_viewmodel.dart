// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/preferences_flags.dart';

import '../models/course.dart';

class DashboardViewModel extends FutureViewModel<Map<String, List<Course>>> {
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
  DateTime selectedDate = DateTime.now();

  /// Marks the viewmodel as busy and calls notify listeners
  void setBusy(bool value) {
    setBusyForObject(this, value);
  }



  /// Get current locale
  Locale get locale => _settingsManager.locale;

  DashboardViewModel({@required AppIntl intl, DateTime initialSelectedDate})
      : _appIntl = intl,
        selectedDate = initialSelectedDate ?? DateTime.now();

  /// Activities for the day currently selected
  List<dynamic> get selectedDateEvents =>
      _coursesActivities[
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day)] ??
          [];

  /// Contains all the courses of the student sorted by session
  final Map<String, List<Course>> coursesBySession = {};



  /// Activities for today
  List<dynamic> get todayDateEvents =>
      _coursesActivities[
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day)] ??
          [];


  /// Chronological order of the sessions. The first index is the most recent
  /// session.
  final List<String> sessionOrder = [];

  bool isLoadingEvents = false;

  @override
  Future<Map<String, List<Course>>> futureToRun() async =>
      _courseRepository.getCourses(fromCacheOnly: true).then((coursesCached) {
        setBusy(true);
        _buildCoursesBySession(coursesCached);
        // ignore: return_type_invalid_for_catch_error
        _courseRepository.getCourses().catchError(onError).then((value) {
          if(value != null) {
            // Update the courses list
            _buildCoursesBySession(_courseRepository.courses);
          }
        }).whenComplete(() {
          setBusy(false);
        });

        return coursesBySession;
      });

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future loadSettings(CalendarController calendarController) async {
    setBusy(true);
    settings.clear();
    settings.addAll(await _settingsManager.getScheduleSettings());
    calendarController.setCalendarFormat(
        settings[PreferencesFlag.scheduleSettingsCalendarFormat]
        as CalendarFormat);
    setBusy(false);
  }

  /// Reload the courses from Signets and rebuild the view.
  Future refresh() async {
    // ignore: return_type_invalid_for_catch_error
    try {
      await _courseRepository.getCourses();
      _buildCoursesBySession(_courseRepository.courses);
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
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
    return _coursesActivities.containsKey(date) ? _coursesActivities[date] : [];
  }


  /// Return session progress based on today's [date]
  double get getSessionProgress {
    final progress = selectedDate
        .difference(_courseRepository.activeSessions.first.startDate)
        .inDays /
        _courseRepository.activeSessions.first.endDate
            .difference(_courseRepository.activeSessions.first.startDate)
            .inDays;

    return progress;
  }

  /// Returns a list containing the number of elapsed days in the active session
  /// and the total number of days in the session
  List<int> get getSessionDays {
    final sessionDays = [
      selectedDate
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays,
      _courseRepository.activeSessions.first.endDate
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays
    ];

    return sessionDays;
  }




  /// Sort [courses] by session.
  void _buildCoursesBySession(List<Course> courses) {
    for (final Course course in courses) {
      coursesBySession.update(course.session, (value) {
        // Remove the current version of the course
        value.removeWhere((element) => element.acronym == course.acronym);
        // Add the updated version of the course
        value.add(course);
        value.sort((a, b) => a.acronym.compareTo(b.acronym));
        return value;
      }, ifAbsent: () {
        sessionOrder.add(course.session);
        return [course];
      });
    }

    sessionOrder.sort((a, b) {
      if (a == b) return 0;

      // When the session is 's.o.' we put the course at the end of the list
      if(a == "s.o.") {
        return 1;
      } else if(b == "s.o.") {
        return -1;
      }

      final yearA = int.parse(a.substring(1));
      final yearB = int.parse(b.substring(1));

      if (yearA < yearB) {
        return 1;
      } else if (yearA == yearB) {
        if (a[0] == 'H' || a[0] == 'É' && b[0] == 'A') {
          return 1;
        }
      }
      return -1;
    });
  }

}
