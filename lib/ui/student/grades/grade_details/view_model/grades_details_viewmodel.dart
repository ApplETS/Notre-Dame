// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_evaluation.dart';
import 'package:notredame/data/services/signets-api/models/signets_errors.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/api_exception.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({required this.course, required AppIntl intl}) : _appIntl = intl;

  List<CourseEvaluation> get _allEvaluations => course.summary?.evaluations ?? [];
  List<CourseEvaluation> get ignoredEvaluations => _allEvaluations.where((e) => e.ignore).toList();
  List<CourseEvaluation> get nonIgnoredEvaluations => _allEvaluations.where((e) => !e.ignore).toList();

  @override
  Future<Course> futureToRun() async {
    try {
      setBusyForObject(course, true);
      course = await _courseRepository.getCourseSummary(course);
      notifyListeners();
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(course, false);
    }
    return course;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    if (error is ApiException) {
      if (error.message.startsWith(SignetsError.gradesNotAvailable) || error.errorCode == SignetsError.gradesEmpty) {
        Fluttertoast.showToast(msg: _appIntl.grades_msg_no_grade);
      } else {
        Fluttertoast.showToast(msg: _appIntl.error);
      }
    }
  }

  Future<bool> refresh() async {
    try {
      setBusyForObject(course, true);
      course = await _courseRepository.getCourseSummary(course);
      notifyListeners();
      return true;
    } catch (error) {
      onError(error);
      return false;
    } finally {
      setBusyForObject(course, false);
    }
  }
}
