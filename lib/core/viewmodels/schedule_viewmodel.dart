// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// OTHER
import 'package:notredame/locator.dart';

class ScheduleViewModel extends FutureViewModel<List<CourseActivity>> {
  final CourseRepository _courseRepository = locator<CourseRepository>();

  Map<DateTime, List<CourseActivity>> _coursesActivities;

  @override
  Future<List<CourseActivity>> futureToRun() =>
      _courseRepository.getCoursesActivities();

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    // TODO toast when fails
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    if (_coursesActivities == null || _coursesActivities.isEmpty) {
      _coursesActivities = {};

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
