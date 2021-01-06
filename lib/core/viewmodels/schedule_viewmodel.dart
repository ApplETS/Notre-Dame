// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// OTHER
import 'package:notredame/locator.dart';

class ScheduleViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// Activities sorted by day
  final Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Day currently selected
  DateTime selectedDate = DateTime.now();

  /// Activities for the day currently selected
  List<dynamic> get selectedDateEvents =>
      _coursesActivities[DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day)] ??
      [];


  bool isLoadingEvents = false;

  @override
  Future<List<CourseActivity>> futureToRun() =>
      _courseRepository.getCoursesActivities(fromCacheOnly: true).then((value) {
        setBusyForObject(isLoadingEvents, true);
        _courseRepository
            .getCoursesActivities()
            .then((value) => setBusyForObject(isLoadingEvents, false));
        return value;
      });

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    // TODO toast when fails
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
    }
    return _coursesActivities;
  }

  /// Get the activities for a specific [date], return empty if there is no activity for this [date]
  List<CourseActivity> coursesActivitiesFor(DateTime date) =>
      _coursesActivities.containsKey(date) ? _coursesActivities[date] : [];
}
