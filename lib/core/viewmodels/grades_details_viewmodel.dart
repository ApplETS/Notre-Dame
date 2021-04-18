// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// MANAGERS / SERVICES
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({@required AppIntl intl, this.course})
      : _appIntl = intl;

  @override
  Future<Course> futureToRun() async {
    try {
      // ignore: return_type_invalid_for_catch_error
      await _courseRepository.getCourseSummary(course).then((value) => course = value);
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    }
  }

  /// Reload the course from Signets and rebuild the view.
  Future<bool> refresh() async {
    try {
      // ignore: return_type_invalid_for_catch_error
      await _courseRepository.getCourseSummary(course).then((value) => course = value);
      notifyListeners();
      return true;
    } on Exception catch (error) {
      onError(error);
      return false;
    }
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
