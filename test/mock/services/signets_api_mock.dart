// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// SERVICE
import 'package:ets_api_clients/clients.dart';
import 'package:ets_api_clients/exceptions.dart';

/// Mock for the [SignetsApi]
class SignetsAPIClientMock extends Mock implements SignetsAPIClient {
  static const signetsException =
      ApiException(prefix: SignetsAPIClient.tag, message: "");

  static const courseRepositoryException =
      ApiException(prefix: CourseRepository.tag, message: "");

  /// Stub the answer of the [authenticate].
  static void stubAuthenticate(SignetsAPIClientMock mock,
      {bool connected = false}) {
    when(mock.authenticate(
            username: anyNamed("username"), password: anyNamed("password")))
        .thenAnswer((_) async => connected);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesActivities(SignetsAPIClientMock mock,
      String session, List<CourseActivity> coursesActivitiesToReturn) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesActivities] with the [session] is used.
  static void stubGetCoursesActivitiesException(
      SignetsAPIClientMock mock, String session,
      {ApiException exceptionToThrow = courseRepositoryException}) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetScheduleActivities(SignetsAPIClientMock mock,
      String session, List<ScheduleActivity> coursesActivitiesToReturn) {
    when(mock.getScheduleActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getScheduleActivities] with the [session] is used.
  static void stubGetScheduleActivitiesException(
      SignetsAPIClientMock mock, String session,
      {ApiException exceptionToThrow = courseRepositoryException}) {
    when(mock.getScheduleActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getSessions] when the [username] is used.
  static void stubGetSessions(SignetsAPIClientMock mock, String username,
      List<Session> sessionsToReturn) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => sessionsToReturn);
  }

  /// Throw [exceptionToThrow] when [getSessions] with the [username] is used.
  static void stubGetSessionsException(
      SignetsAPIClientMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getPrograms] when the [username] is used.
  static void stubGetPrograms(SignetsAPIClientMock mock, String username,
      List<Program> programsToReturn) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => programsToReturn);
  }

  /// Throw [exceptionToThrow] when [getPrograms] with the [username] is used.
  static void stubGetProgramsException(
      SignetsAPIClientMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getInfo] when the [username] is used.
  static void stubGetInfo(
      SignetsAPIClientMock mock, String username, ProfileStudent infoToReturn) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenAnswer((_) async => infoToReturn);
  }

  /// Throw [exceptionToThrow] when [getInfo] with the [username] is used.
  static void stubGetInfoException(SignetsAPIClientMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourses] when the [username] is used.
  static void stubGetCourses(SignetsAPIClientMock mock, String username,
      {List<Course> coursesToReturn = const []}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => coursesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourses] with the [username] is used.
  static void stubGetCoursesException(
      SignetsAPIClientMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseSummary] when the [username] and [course] is used.
  static void stubGetCourseSummary(
      SignetsAPIClientMock mock, String username, Course course,
      {CourseSummary summaryToReturn}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenAnswer((_) async => summaryToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourseSummary] with the [username] and [course] is used.
  static void stubGetCourseSummaryException(
      SignetsAPIClientMock mock, String username, Course course,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesEvaluation] when the [username] and [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCoursesEvaluation(
      SignetsAPIClientMock mock, String username,
      {Session session,
      List<CourseEvaluation> evaluationsToReturn = const []}) {
    when(mock.getCoursesEvaluation(
            username: username,
            session: session ?? anyNamed('session'),
            password: anyNamed("password")))
        .thenAnswer((_) async => evaluationsToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesEvaluation] with the [username] and [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCoursesEvaluationException(
      SignetsAPIClientMock mock, String username,
      {Session session, ApiException exceptionToThrow = signetsException}) {
    when(mock.getCoursesEvaluation(
            username: username,
            session: session ?? anyNamed('session'),
            password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }
}
