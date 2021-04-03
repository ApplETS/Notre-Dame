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

// TODO Replace FutureViewModel<List<CourseActivity>> by FutureViewModel
class DashboardViewModel extends FutureViewModel<List<CourseActivity>> {
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

  DashboardViewModel({@required AppIntl intl})
      : _appIntl = intl,
        selectedDate = DateTime.now();

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
      DateTime(selectedDate.year, 3, 31)] ??
          [];

  /// Chronological order of the sessions. The first index is the most recent
  /// session.
  final List<String> sessionOrder = [];

  bool isLoadingEvents = false;


  @override
  // TODO Remove Map<String, List<Course>>
  Future<Map<String, List<Course>>> futureToRun() async =>
      /* TODO Load settings to get all the cards to displayed
          Then call the future needed for each visible cards using
          setBusyForObject(objectUsedByTheCards, true) (dont forget to turn it
          off after the future is loaded).
          So you will need a function (future) for each card and an object for
          each card.
          For example:
            - Schedule card:
                - object: List<CourseActivities> coursesActivities.
                - function: Future<List<CourseActivities>> loadCoursesActivities()
                   this function will call:
                      setBusyForObject(coursesActivities, true)
                      CourseRepository.getCoursesActivities(fromCacheOnly: true)
                      Do some logic to get the activities of today
                      setBusyForObject(coursesActivities, false) //reload the UI
                      setBusyForObject(coursesActivities, true)
                      CourseRepository.getCoursesActivities()
                      Do some logic to get the activities of today
                      setBusyForObject(coursesActivities, false) //reload the UI
       */
      _courseRepository.getCourses(fromCacheOnly: true).then((coursesCached) {
        setBusy(true);
        _buildCoursesBySession(coursesCached);
        // ignore: return_type_invalid_for_catch_error
        _courseRepository.getCourses().catchError(onError).then((value) {
          if (value != null) {
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
    double progress = 0;
    if(_courseRepository.activeSessions.first.startDate.isBefore(DateTime.now())) {
       progress = selectedDate
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays /
          _courseRepository.activeSessions.first.endDate
              .difference(_courseRepository.activeSessions.first.startDate)
              .inDays;
    }
    else{
       progress = 10;
    }
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



}
