// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/course.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/course_review.dart';
import 'package:notredame/domain/models/signets-api/course_summary.dart';
import 'package:notredame/domain/models/signets-api/profile_student.dart';
import 'package:notredame/domain/models/signets-api/program.dart';
import 'package:notredame/domain/models/signets-api/replaced_day.dart';
import 'package:notredame/domain/models/signets-api/schedule_activity.dart';
import 'package:notredame/domain/models/signets-api/schedule_and_teachers.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/utils/api_exception.dart';
import 'signets_client_mock.mocks.dart';

SignetsApiResponse<T> _ok<T>(T data) => SignetsApiResponse(data: data, error: "");

@GenerateNiceMocks([MockSpec<SignetsClient>()])
class SignetsClientMock extends MockSignetsClient {
  static const signetsException = ApiException(prefix: SignetsClient.tag);

  /// Stub the answer of the [getSessionList]
  static void stubGetSessionList(MockSignetsClient mock, List<Session> sessionsToReturn) {
    when(mock.getSessionList()).thenAnswer((_) async => _ok(sessionsToReturn));
  }

  /// Throw [exceptionToThrow] when [getSessionList] is used.
  static void stubGetSessionListException(MockSignetsClient mock, {Exception exceptionToThrow = signetsException}) {
    when(mock.getSessionList()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesActivities(
    MockSignetsClient mock,
    String session,
    List<CourseActivity> coursesActivitiesToReturn,
  ) {
    when(mock.getCoursesActivities(session)).thenAnswer((_) async => _ok(coursesActivitiesToReturn));
  }

  /// Throw [exceptionToThrow] when [getCoursesActivities] with the [session] is used.
  static void stubGetCoursesActivitiesException(
    MockSignetsClient mock,
    String session, {
    required Exception exceptionToThrow,
  }) {
    when(mock.getCoursesActivities(session)).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getScheduleActivities] when the [session] is used.
  static void stubGetScheduleActivities(
    MockSignetsClient mock,
    String session,
    List<ScheduleActivity> scheduleActivitiesToReturn,
  ) {
    when(
      mock.getScheduleActivities(session),
    ).thenAnswer((_) async => _ok(ScheduleAndTeachers(activities: scheduleActivitiesToReturn)));
  }

  /// Throw [exceptionToThrow] when [getScheduleActivities] with the [session] is used.
  static void stubGetScheduleActivitiesException(
    MockSignetsClient mock,
    String session, {
    required Exception exceptionToThrow,
  }) {
    when(mock.getScheduleActivities(session)).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getPrograms]
  static void stubGetPrograms(MockSignetsClient mock, List<Program> programsToReturn) {
    when(mock.getPrograms()).thenAnswer((_) async => _ok(programsToReturn));
  }

  /// Throw [exceptionToThrow] when [getPrograms]
  static void stubGetProgramsException(MockSignetsClient mock, {Exception exceptionToThrow = signetsException}) {
    when(mock.getPrograms()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getStudentInfo]
  static void stubGetInfo(MockSignetsClient mock, ProfileStudent infoToReturn) {
    when(mock.getStudentInfo()).thenAnswer((_) async => _ok(infoToReturn));
  }

  /// Throw [exceptionToThrow] when [getStudentInfo]
  static void stubGetInfoException(MockSignetsClient mock, {Exception exceptionToThrow = signetsException}) {
    when(mock.getStudentInfo()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourses]
  static void stubGetCourses(MockSignetsClient mock, {List<Course> coursesToReturn = const []}) {
    when(mock.getCourses()).thenAnswer((_) async => _ok(coursesToReturn));
  }

  /// Throw [exceptionToThrow] when [getCourses]
  static void stubGetCoursesException(MockSignetsClient mock, {Exception exceptionToThrow = signetsException}) {
    when(mock.getCourses()).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getReplacedDays] when the [session] is used.
  static void stubGetReplacedDays(MockSignetsClient mock, String session, List<ReplacedDay> replacedDaysToReturn) {
    when(mock.getReplacedDays(session)).thenAnswer((_) async => _ok(replacedDaysToReturn));
  }

  /// Throw [exceptionToThrow] when [getReplacedDays] with the [session] is used.
  static void stubGetReplacedDaysException(
    MockSignetsClient mock,
    String session, {
    required Exception exceptionToThrow,
  }) {
    when(mock.getReplacedDays(session)).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseSummary] when the [course] is used.
  static void stubGetCourseSummary(MockSignetsClient mock, Course course, {CourseSummary? summaryToReturn}) {
    when(
      mock.getCourseSummary(course.session, course.acronym, course.group),
    ).thenAnswer((_) async => _ok(summaryToReturn!));
  }

  /// Throw [exceptionToThrow] when [getCourseSummary] when the [course] is used.
  static void stubGetCourseSummaryException(
    MockSignetsClient mock,
    Course course, {
    Exception exceptionToThrow = signetsException,
  }) {
    when(mock.getCourseSummary(course.session, course.acronym, course.group)).thenThrow(exceptionToThrow);
  }

  /// Stub the answer of the [getCourseReviews] when the [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviews(
    MockSignetsClient mock, {
    Session? session,
    List<CourseReview> reviewsToReturn = const [],
  }) {
    when(mock.getCourseReviews(session?.shortName ?? any)).thenAnswer((_) async => _ok(reviewsToReturn));
  }

  /// Throw [exceptionToThrow] when [getCourseReviews] when the [session] is used.
  /// If [session] is null any session will be accepted.
  static void stubGetCourseReviewsException(
    MockSignetsClient mock, {
    Session? session,
    Exception exceptionToThrow = signetsException,
  }) {
    when(mock.getCourseReviews(session?.shortName ?? any)).thenThrow(exceptionToThrow);
  }
}
