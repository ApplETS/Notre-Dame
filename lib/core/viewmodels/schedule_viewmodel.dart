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
  DateTime selectedDate = DateTime.now();

  /// Get current locale
  Locale get locale => _settingsManager.locale;

  /// Verify if user has an active internet connection
  final NetworkingService _networkingService = locator<NetworkingService>();

  ScheduleViewModel({@required AppIntl intl, DateTime initialSelectedDate})
      : _appIntl = intl,
        selectedDate = initialSelectedDate ?? DateTime.now();

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
          Utils.showNoConnectionToast(_networkingService, _appIntl);
        });
        return value;
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
