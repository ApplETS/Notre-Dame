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
  final Course _course;

  Course get course => _course;

  GradesDetailsViewModel({@required AppIntl intl, @required Course course})
      : _appIntl = intl,
        _course = course;

  bool isLoadingEvents = false;

  @override
  Future<Course> futureToRun() async => _courseRepository
      .getCourseSummary(course)
      .then((value) {
        setBusyForObject(isLoadingEvents, true);
      })
      // ignore: return_type_invalid_for_catch_error
      .catchError(onError)
      .whenComplete(() => setBusyForObject(isLoadingEvents, false));

  /// Reload the course from Signets and rebuild the view.
  Future<bool> refresh() async {
    try {
      _courseRepository
          .getCourseSummary(course)
          .then((value) {
            setBusyForObject(isLoadingEvents, true);
          })
          // ignore: return_type_invalid_for_catch_error
          .catchError(onError)
          .whenComplete(() => setBusyForObject(isLoadingEvents, false));
      notifyListeners();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
