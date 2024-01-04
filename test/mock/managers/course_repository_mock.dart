// Package imports:
import 'package:ets_api_clients/exceptions.dart';
import 'package:ets_api_clients/models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';

import 'course_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<CourseRepository>()])
class CourseRepositoryMock extends MockCourseRepository {
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
      {List<CourseActivity> toReturn = const [], bool fromCacheOnly = false}) {
    when(mock.getCoursesActivities(
            fromCacheOnly: fromCacheOnly))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getCoursesActivities] of [mock] when called will throw [toThrow].
  static void stubGetCoursesActivitiesException(CourseRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'),
      bool fromCacheOnly = false}) {
    when(mock.getCoursesActivities(
            fromCacheOnly: fromCacheOnly))
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
      {Exception toThrow = const ApiException(prefix: 'ApiException')}) {
    when(mock.getSessions()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [getCourses] of [mock] when called will return [toReturn].
  static void stubGetCourses(CourseRepositoryMock mock,
      {List<Course> toReturn = const [], bool fromCacheOnly = false}) {
    when(mock.getCourses(
            fromCacheOnly: fromCacheOnly))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [courses] of [mock] when called will return [toReturn].
  static void stubCourses(CourseRepositoryMock mock,
      {List<Course> toReturn = const []}) {
    when(mock.courses).thenAnswer((realInvocation) => toReturn);
  }

  /// Stub the function [getCourses] of [mock] when called will throw [toThrow].
  static void stubGetCoursesException(CourseRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'),
      bool fromCacheOnly = false}) {
    when(mock.getCourses(
            fromCacheOnly: fromCacheOnly))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [getCourseSummary] of [mock] when called will return [toReturn].
  static void stubGetCourseSummary(
      CourseRepositoryMock mock, Course courseCalled,
      {required Course toReturn}) {
    when(mock.getCourseSummary(courseCalled)).thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getCourseSummary] of [mock] when called will throw [toThrow].
  static void stubGetCourseSummaryException(
      CourseRepositoryMock mock, Course courseCalled,
      {Exception toThrow = const ApiException(prefix: 'ApiException')}) {
    when(mock.getCourseSummary(courseCalled)).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [getScheduleActivities] of [mock] when called will return [toReturn].
  static void stubGetScheduleActivities(CourseRepositoryMock mock,
      {List<ScheduleActivity> toReturn = const [], bool fromCacheOnly = false}) {
    when(mock.getScheduleActivities(
            fromCacheOnly: fromCacheOnly))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getScheduleActivities] of [mock] when called will throw [toThrow].
  static void stubGetScheduleActivitiesException(
      CourseRepositoryMock mock, Course courseCalled,
      {Exception toThrow = const ApiException(prefix: 'ApiException')}) {
    when(mock.getScheduleActivities()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }
}
