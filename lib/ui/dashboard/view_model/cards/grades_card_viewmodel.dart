// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class GradesCardViewmodel extends FutureViewModel {
  static const String abandonedGradeCode = "XX";

  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// List of courses for the current session
  List<Course> courses = [];

  final AppIntl _appIntl;

  GradesCardViewmodel({required AppIntl intl}) : _appIntl = intl;

  /// Get the list of courses for the Grades card.
  @override
  Future<List<Course>> futureToRun() async {
    if (!busy(courses)) {
      try {
        setBusyForObject(courses, true);
        if (_courseRepository.sessions == null || _courseRepository.sessions!.isEmpty) {
          await _courseRepository.getSessions();
        }

        // Determine current sessions
        if (_courseRepository.activeSessions.isEmpty) {
          return [];
        }
        final currentSession = _courseRepository.activeSessions.first;

        final coursesCached = await _courseRepository.getCourses(fromCacheOnly: true);
        courses.clear();
        for (final Course course in coursesCached) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
            courses.add(course);
          }
        }
        notifyListeners();

        final fetchedCourses = await _courseRepository.getCourses();
        // Update the courses list
        courses.clear();
        for (final Course course in fetchedCourses) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
            courses.add(course);
          }
        }
        // Will remove duplicated courses in the list
        courses = courses.toSet().toList();
      } catch (e) {
        onError(e, null);
      } finally {
        setBusyForObject(courses, false);
      }
    }
    return courses;
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
