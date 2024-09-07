import 'package:stacked/stacked.dart';

import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/repository/course_repository.dart';

class GradesCardViewModel extends FutureViewModel<List<Course>> {
  final CourseRepository _courseRepository = locator<CourseRepository>();

  @override
  Future<List<Course>> futureToRun() async {
    try {
      if (_courseRepository.sessions == null ||
          _courseRepository.sessions!.isEmpty) {
        await _courseRepository.getSessions();
      }

      if (_courseRepository.activeSessions.isEmpty) {
        return [];
      }
      final currentSession = _courseRepository.activeSessions.first;

      final fetchedCourses = await _courseRepository.getCourses();

      return fetchedCourses
          .where((course) => course.session == currentSession.shortName)
          .toList();
    } catch (error) {
      onError(error);
    }
    return <Course>[];
  }
}
