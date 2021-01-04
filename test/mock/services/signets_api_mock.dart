// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/utils/api_exception.dart';

/// Mock for the [SignetsApi]
class SignetsApiMock extends Mock implements SignetsApi {
  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesActivities(SignetsApiMock mock, String session,
      List<CourseActivity> coursesActivitiesToReturn) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesActivities] with the [session] is used.
  static void stubGetCoursesActivitiesException(
      SignetsApiMock mock, String session,
      {ApiException exceptionToThrow =
          const ApiException(prefix: CourseRepository.tag, message: "")}) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getSessions] when the [username] is used.
  static void stubGetSessions(
      SignetsApiMock mock, String username, List<Session> sessionsToReturn) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => sessionsToReturn);
  }

  /// Throw [exceptionToThrow] when [getSessions] with the [username] is used.
  static void stubGetSessionsException(SignetsApiMock mock, String username,
      {ApiException exceptionToThrow =
          const ApiException(prefix: SignetsApi.tag, message: "")}) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }
}
