// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// MANAGERS / SERVICES
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// OTHER
import 'package:notredame/locator.dart';

class GradesDetailsViewModel extends FutureViewModel<Course> {
  /// Used to get the courses of the student
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Used to get the current course selected of the student
  Course course;

  GradesDetailsViewModel({this.course});

  @override
  Future<Course> futureToRun() async {
    try {
      await _courseRepository.getCourseSummary(course)?.then((value) {
        if (value != null) {
          course = value;
        }
      });
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    }

    return course;
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
