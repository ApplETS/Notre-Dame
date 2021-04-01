// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// MODEL
import 'package:notredame/core/models/course.dart';

// OTHER
import 'package:notredame/locator.dart';

class GradesViewModel extends FutureViewModel<Map<String, List<Course>>> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Contains all the courses of the student sorted by session
  final Map<String, List<Course>> coursesBySession = {};

  /// Chronological order of the sessions. The first index is the most recent
  /// session.
  final List<String> sessionOrder = [];

  GradesViewModel({@required AppIntl intl}) : _appIntl = intl;

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
