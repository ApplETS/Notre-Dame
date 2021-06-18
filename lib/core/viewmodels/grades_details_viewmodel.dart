// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS / SERVICES
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/services/networking_service.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';

// OTHER
import 'package:notredame/locator.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  // Used to check for user connectivity status
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({this.course, @required AppIntl intl})
      : _appIntl = intl;

  @override
  Future<Course> futureToRun() async {
    setBusyForObject(course, true);

    // ignore: return_type_invalid_for_catch_error
    await _courseRepository
        .getCourseSummary(course)
        // ignore: return_type_invalid_for_catch_error
        .catchError(onError)
        ?.then((value) {
      if (value != null) {
        course = value;
      }
    })?.whenComplete(() {
      Utils.showNoConnectionToast(_networkingService, _appIntl);
      setBusyForObject(course, false);
    });

    notifyListeners();

    return course;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future<bool> refresh() async {
    try {
      setBusyForObject(course, true);
      await _courseRepository.getCourseSummary(course)?.then((value) {
        if (value != null) {
          course = value;
        }
      });
      notifyListeners();
      setBusyForObject(course, false);
      return true;
    } on Exception catch (error) {
      onError(error);
      setBusyForObject(course, false);
      return false;
    }
  }
}
