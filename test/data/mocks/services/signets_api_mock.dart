// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/api_exception.dart';
import 'signets_api_mock.mocks.dart';

// MODELS

// SERVICE

/// Mock for the [SignetsApi]
@GenerateNiceMocks([MockSpec<SignetsAPIClient>()])
class SignetsAPIClientMock extends MockSignetsAPIClient {
  static const signetsException = ApiException(prefix: SignetsAPIClient.tag);

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesActivities(MockSignetsAPIClient mock,
      String session, List<CourseActivity> coursesActivitiesToReturn) {
    when(mock.getCoursesActivities(session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesActivities] with the [session] is used.
  static void stubGetCoursesActivitiesException(
      MockSignetsAPIClient mock, String session,
      {required ApiException exceptionToThrow}) {
    when(mock.getCoursesActivities(session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetScheduleActivities(MockSignetsAPIClient mock,
      String session, List<ScheduleActivity> coursesActivitiesToReturn) {
    when(mock.getScheduleActivities(session: session))
        .thenAnswer((_) async => coursesActivitiesToReturn);
  }

  /// Throw [exceptionToThrow] when [getScheduleActivities] with the [session] is used.
  static void stubGetScheduleActivitiesException(
      MockSignetsAPIClient mock, String session,
      {required ApiException exceptionToThrow}) {
    when(mock.getScheduleActivities(session: session))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getSessions]
  static void stubGetSessions(
      MockSignetsAPIClient mock, List<Session> sessionsToReturn) {
    when(mock.getSessions()).thenAnswer((_) async => sessionsToReturn);
  }

  /// Throw [exceptionToThrow] when [getSessions]
  static void stubGetSessionsException(MockSignetsAPIClient mock,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getSessions()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getPrograms]
  static void stubGetPrograms(
      MockSignetsAPIClient mock, List<Program> programsToReturn) {
    when(mock.getPrograms()).thenAnswer((_) async => programsToReturn);
  }

  /// Throw [exceptionToThrow] when [getPrograms]
  static void stubGetProgramsException(MockSignetsAPIClient mock,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getPrograms()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getInfo]
  static void stubGetInfo(
      MockSignetsAPIClient mock, ProfileStudent infoToReturn) {
    when(mock.getStudentInfo()).thenAnswer((_) async => infoToReturn);
  }

  /// Throw [exceptionToThrow] when [getInfo]
  static void stubGetInfoException(MockSignetsAPIClient mock,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getStudentInfo()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourses]
  static void stubGetCourses(MockSignetsAPIClient mock,
      {List<Course> coursesToReturn = const []}) {
    when(mock.getCourses()).thenAnswer((_) async => coursesToReturn);
  }

  /// Throw [exceptionToThrow] when [getCourses]
  static void stubGetCoursesException(MockSignetsAPIClient mock,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourses()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseSummary] when the [course] is used.
  static void stubGetCourseSummary(MockSignetsAPIClient mock, Course course,
      {CourseSummary? summaryToReturn}) {
    when(mock.getCourseSummary(
            session: course.session,
            acronym: course.acronym,
            group: course.group))
        .thenAnswer((_) async => summaryToReturn!);
  }

  /// Throw [exceptionToThrow] when [getCourseSummary] when the [course] is used.
  static void stubGetCourseSummaryException(
      MockSignetsAPIClient mock, Course course,
      {ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseSummary(
            session: course.session,
            acronym: course.acronym,
            group: course.group))
        .thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesReviews] when the [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviews(MockSignetsAPIClient mock,
      {Session? session, List<CourseReview> reviewsToReturn = const []}) {
    when(mock.getCourseReviews(
            session: session?.shortName ?? anyNamed('session')))
        .thenAnswer((_) async => reviewsToReturn);
  }

  /// Throw [exceptionToThrow] when [getCoursesReviews] when the [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviewsException(MockSignetsAPIClient mock,
      {Session? session, ApiException exceptionToThrow = signetsException}) {
    when(mock.getCourseReviews(
            session: session?.shortName ?? anyNamed('session')))
        .thenThrow(exceptionToThrow);
  }
}
