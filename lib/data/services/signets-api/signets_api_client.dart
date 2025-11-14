// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/signets-api/commands/get_course_reviews_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_course_summary_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_courses_activities_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_courses_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_programs_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_schedule_activities_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_sessions_command.dart';
import 'package:notredame/data/services/signets-api/commands/get_student_info_command.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import '../../../locator.dart';

/// A Wrapper for all calls to Signets API.
class SignetsAPIClient {
  static const String tag = "SignetsApi";
  static const String tagError = "$tag - Error";

  late final http.Client _httpClient;
  final _authService = locator<AuthService>();
  final Logger _logger = locator<Logger>();

  SignetsAPIClient({http.Client? httpClient}) {
    _httpClient = httpClient ?? IOClient(_createHttpClientWithCert());
  }

  /// Load and attach a custom certificate to the [HttpClient]
  HttpClient _createHttpClientWithCert() {
    final context = SecurityContext.defaultContext;

    rootBundle
        .load('assets/certificates/signets_cert.crt')
        .then((data) {
          context.setTrustedCertificatesBytes(data.buffer.asUint8List());
          _logger.d("$tag - Certificate loaded successfully");
        })
        .catchError((e) {
          _logger.e("$tag - Failed to load certificate: $e");
        });

    return HttpClient(context: context);
  }

  /// Expression to validate the format of a session short name (ex: A2020)
  final RegExp _sessionShortNameRegExp = RegExp("^([A-É-H][0-9]{4})");

  /// Expression to validate the format of a course (ex: MAT256-01)
  final RegExp _courseGroupRegExp = RegExp("^([A-Z]{3}[0-9]{3}-[0-9]{2})");

  /// Call the SignetsAPI to get the courses activities for the [session] for
  /// the student. By specifying [courseGroup] we can filter the
  /// results to get only the activities for this course.
  /// If the [startDate] and/or [endDate] are specified the results will contain
  /// all the activities between these dates
  Future<List<CourseActivity>> getCoursesActivities({
    String session = "",
    String courseGroup = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final command = GetCoursesActivitiesCommand(
      this,
      _httpClient,
      _sessionShortNameRegExp,
      _courseGroupRegExp,
      token: await _authService.getToken(),
      session: session,
      courseGroup: courseGroup,
      startDate: startDate,
      endDate: endDate,
    );
    return command.execute();
  }

  /// Call the SignetsAPI to get the courses activities for the [session] for
  /// the student.
  Future<List<ScheduleActivity>> getScheduleActivities({String session = ""}) async {
    final command = GetScheduleActivitiesCommand(
      this,
      _httpClient,
      _sessionShortNameRegExp,
      token: await _authService.getToken(),
      session: session,
    );
    return command.execute();
  }

  /// Call the SignetsAPI to get the courses of the student.
  Future<List<Course>> getCourses() async {
    final command = GetCoursesCommand(this, _httpClient, token: await _authService.getToken());
    return command.execute();
  }

  /// Call the SignetsAPI to get all the evaluations (exams) and the summary
  /// of [course] for the student.
  Future<CourseSummary> getCourseSummary({
    required String session,
    required String acronym,
    required String group,
  }) async {
    final command = GetCourseSummaryCommand(
      this,
      _httpClient,
      token: await _authService.getToken(),
      session: session,
      acronym: acronym,
      group: group,
    );
    return command.execute();
  }

  /// Call the SignetsAPI to get the list of all the [Session] for the student.
  Future<List<Session>> getSessions() async {
    final command = GetSessionsCommand(this, _httpClient, token: await _authService.getToken());
    return command.execute();
  }

  /// Call the SignetsAPI to get the [ProfileStudent] for the student.
  Future<ProfileStudent> getStudentInfo() async {
    final command = GetStudentInfoCommand(this, _httpClient, token: await _authService.getToken());
    return command.execute();
  }

  /// Call the SignetsAPI to get the list of all the [Program] for the student.
  Future<List<Program>> getPrograms() async {
    final command = GetProgramsCommand(this, _httpClient, token: await _authService.getToken());
    return command.execute();
  }

  /// Call the SignetsAPI to get the list of all [CourseReview] for the [session]
  /// of the student.
  Future<List<CourseReview>> getCourseReviews({required String session}) async {
    final command = GetCourseReviewsCommand(this, _httpClient, token: await _authService.getToken(), session: session);
    return command.execute();
  }
}
