// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/course.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/utils/api_exception.dart';

class CourseRepositoryMock extends Mock implements CourseRepository {
  /// Stub the getter [courses] of [mock] when called will return [toReturn].
  static void stubCourses(CourseRepositoryMock mock,
      {List<Course> toReturn = const []}) {
    when(mock.courses).thenReturn(toReturn);
  }

  /// Stub the getter [coursesActivities] of [mock] when called will return [toReturn].
  static void stubCoursesActivities(CourseRepositoryMock mock,
      {List<CourseActivity> toReturn = const []}) {
    when(mock.coursesActivities).thenReturn(toReturn);
  }

  /// Stub the getter [sessions] of [mock] when called will return [toReturn].
  static void stubSessions(CourseRepositoryMock mock,
      {List<Session> toReturn = const []}) {
    when(mock.sessions).thenReturn(toReturn);
  }

  /// Stub the getter [activeSessions] of [mock] when called will return [toReturn].
  static void stubActiveSessions(CourseRepositoryMock mock,
      {List<Session> toReturn = const []}) {
    when(mock.activeSessions).thenReturn(toReturn);
  }

  /// Stub the function [getCoursesActivities] of [mock] when called will return [toReturn].
  static void stubGetCoursesActivities(CourseRepositoryMock mock,
      {List<CourseActivity> toReturn = const [], bool fromCacheOnly}) {
    when(mock.getCoursesActivities(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getCoursesActivities] of [mock] when called will throw [toThrow].
  static void stubGetCoursesActivitiesException(CourseRepositoryMock mock,
      {Exception toThrow =
          const ApiException(prefix: 'ApiException', message: ''),
      bool fromCacheOnly}) {
    when(mock.getCoursesActivities(
            fromCacheOnly: fromCacheOnly ?? anyNamed("fromCacheOnly")))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [getSessions] of [mock] when called will return [toReturn].
  static void stubGetSessions(CourseRepositoryMock mock,
      {List<Session> toReturn = const []}) {
    when(mock.getSessions()).thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getSessions] of [mock] when called will throw [toThrow].
  static void stubGetSessionsException(CourseRepositoryMock mock,
      {Exception toThrow =
          const ApiException(prefix: 'ApiException', message: '')}) {
    when(mock.getSessions()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }
}
