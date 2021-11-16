// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/course_evaluation.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:notredame/core/models/schedule_activity.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/models/course.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/utils/api_exception.dart';

/// Mock for the [SignetsApi]
class SignetsApiMock extends Mock implements SignetsApi {
  static const signetsException =
      ApiException(prefix: SignetsApi.tag, message: "");

  static const courseRepositoryException =
      ApiException(prefix: CourseRepository.tag, message: "");

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
      {ApiException exceptionToThrow = courseRepositoryException}) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetScheduleActivities(SignetsApiMock mock, String session,
      List<ScheduleActivity> coursesActivitiesToReturn) {
    when(mock.getScheduleActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getScheduleActivities] with the [session] is used.
  static void stubGetScheduleActivitiesException(
      SignetsApiMock mock, String session,
      {ApiException exceptionToThrow = courseRepositoryException}) {
    when(mock.getScheduleActivities(
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
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getPrograms] when the [username] is used.
  static void stubGetPrograms(
      SignetsApiMock mock, String username, List<Program> programsToReturn) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => programsToReturn);
  }

  /// Throw [exceptionToThrow] when [getPrograms] with the [username] is used.
  static void stubGetProgramsException(SignetsApiMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getInfo] when the [username] is used.
  static void stubGetInfo(
      SignetsApiMock mock, String username, ProfileStudent infoToReturn) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenAnswer((_) async => infoToReturn);
  }

  /// Throw [exceptionToThrow] when [getInfo] with the [username] is used.
  static void stubGetInfoException(SignetsApiMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourses] when the [username] is used.
  static void stubGetCourses(SignetsApiMock mock, String username,
      {List<Course> coursesToReturn = const []}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => coursesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourses] with the [username] is used.
  static void stubGetCoursesException(SignetsApiMock mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseSummary] when the [username] and [course] is used.
  static void stubGetCourseSummary(
      SignetsApiMock mock, String username, Course course,
      {CourseSummary summaryToReturn}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenAnswer((_) async => summaryToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourseSummary] with the [username] and [course] is used.
  static void stubGetCourseSummaryException(
      SignetsApiMock mock, String username, Course course,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesEvaluation] when the [username] and [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCoursesEvaluation(SignetsApiMock mock, String username,
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
      SignetsApiMock mock, String username,
      {Session session, ApiException exceptionToThrow = signetsException}) {
    when(mock.getCoursesEvaluation(
            username: username,
            session: session ?? anyNamed('session'),
            password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }
}
