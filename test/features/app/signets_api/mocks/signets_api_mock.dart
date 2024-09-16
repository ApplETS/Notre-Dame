// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/course_review.dart';
import 'package:notredame/features/app/signets-api/models/course_summary.dart';
import 'package:notredame/features/app/signets-api/models/profile_student.dart';
import 'package:notredame/features/app/signets-api/models/program.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/utils/api_exception.dart';
import 'signets_api_mock.mocks.dart';

// MODELS

// SERVICE

/// Mock for the [SignetsApi]
@GenerateNiceMocks([MockSpec<SignetsAPIClient>()])
class SignetsAPIClientMock extends MockSignetsAPIClient {
  static const signetsException = ApiException(prefix: SignetsAPIClient.tag);

  // ignore: deprecated_member_use_from_same_package
  /// Stub the answer of the [authenticate].
  static void stubAuthenticate(MockSignetsAPIClient mock,
      {bool connected = false}) {
    // ignore: deprecated_member_use_from_same_package
    when(mock.authenticate(
            username: anyNamed("username"), password: anyNamed("password")))
        .thenAnswer((_) async => connected);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesActivities(MockSignetsAPIClient mock,
      String session, List<CourseActivity> coursesActivitiesToReturn) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesActivities] with the [session] is used.
  static void stubGetCoursesActivitiesException(
      MockSignetsAPIClient mock, String session,
      {required ApiException exceptionToThrow}) {
    when(mock.getCoursesActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetScheduleActivities(MockSignetsAPIClient mock,
      String session, List<ScheduleActivity> coursesActivitiesToReturn) {
    when(mock.getScheduleActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getScheduleActivities] with the [session] is used.
  static void stubGetScheduleActivitiesException(
      MockSignetsAPIClient mock, String session,
      {required ApiException exceptionToThrow}) {
    when(mock.getScheduleActivities(
            username: anyNamed("username"),
            password: anyNamed("password"),
            session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getSessions] when the [username] is used.
  static void stubGetSessions(MockSignetsAPIClient mock, String username,
      List<Session> sessionsToReturn) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => sessionsToReturn);
  }

  /// Throw [exceptionToThrow] when [getSessions] with the [username] is used.
  static void stubGetSessionsException(
      MockSignetsAPIClient mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getSessions(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getPrograms] when the [username] is used.
  static void stubGetPrograms(MockSignetsAPIClient mock, String username,
      List<Program> programsToReturn) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => programsToReturn);
  }

  /// Throw [exceptionToThrow] when [getPrograms] with the [username] is used.
  static void stubGetProgramsException(
      MockSignetsAPIClient mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getPrograms(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getInfo] when the [username] is used.
  static void stubGetInfo(
      MockSignetsAPIClient mock, String username, ProfileStudent infoToReturn) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenAnswer((_) async => infoToReturn);
  }

  /// Throw [exceptionToThrow] when [getInfo] with the [username] is used.
  static void stubGetInfoException(MockSignetsAPIClient mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getStudentInfo(
            username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourses] when the [username] is used.
  static void stubGetCourses(MockSignetsAPIClient mock, String username,
      {List<Course> coursesToReturn = const []}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenAnswer((_) async => coursesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourses] with the [username] is used.
  static void stubGetCoursesException(
      MockSignetsAPIClient mock, String username,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourses(username: username, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseSummary] when the [username] and [course] is used.
  static void stubGetCourseSummary(
      MockSignetsAPIClient mock, String username, Course course,
      {CourseSummary? summaryToReturn}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenAnswer((_) async => summaryToReturn!);
  }

  /// Throw [exceptionToThrow] when [getCourseSummary] with the [username] and [course] is used.
  static void stubGetCourseSummaryException(
      MockSignetsAPIClient mock, String username, Course course,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseSummary(
            username: username, course: course, password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesReviews] when the [username] and [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviews(MockSignetsAPIClient mock, String username,
      {Session? session, List<CourseReview> reviewsToReturn = const []}) {
    when(mock.getCourseReviews(
            username: username,
            session: session ?? anyNamed('session'),
            password: anyNamed("password")))
        .thenAnswer((_) async => reviewsToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesReviews] with the [username] and [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviewsException(
      MockSignetsAPIClient mock, String username,
      {Session? session, ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseReviews(
            username: username,
            session: session ?? anyNamed('session'),
            password: anyNamed("password")))
        .thenThrow(exceptionToThrow);
  }
}
