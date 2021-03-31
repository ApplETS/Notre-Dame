// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  Course course;

  CourseSummary courseSummary;

  GradesDetailsViewModel({@required AppIntl intl, @required Course course})
      : _appIntl = intl,
        course = course;

  /// Reload the grades from Signets and rebuild the view.
  Future<bool> refresh() async {
    try {
      _courseRepository
          .getCourseSummary(course)
          .catchError(onError)
          .then((value) {
        course = value;
      });
      notifyListeners();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<Course> futureToRun() async => _courseRepository
          .getCourseSummary(course)
          .catchError(onError)
          .then((value) {
        course = value;
      });

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
