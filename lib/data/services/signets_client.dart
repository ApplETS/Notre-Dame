// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/course.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/course_review.dart';
import 'package:notredame/domain/models/signets-api/course_summary.dart';
import 'package:notredame/domain/models/signets-api/profile_student.dart';
import 'package:notredame/domain/models/signets-api/program.dart';
import 'package:notredame/domain/models/signets-api/replaced_day.dart';
import 'package:notredame/domain/models/signets-api/schedule_and_teachers.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/domain/models/signets-api/signets_errors.dart';
import 'package:notredame/utils/api_exception.dart';

part 'signets_client.g.dart';

@RestApi(baseUrl: 'https://etsmobileapi.etsmtl.ca/api/Etudiant/')
abstract class SignetsClient {
  static const String tag = "SignetsClient";
  static const String tagError = "$tag - Error";

  factory SignetsClient(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SignetsClient;

  /// Get the profile of the student
  @GET('/infoEtudiant')
  Future<SignetsApiResponse<ProfileStudent>> getStudentInfo();

  /// Get the list of all the courses of the student
  @GET('/listeCours')
  Future<SignetsApiResponse<List<Course>>> getCourses();

  /// Get the list of the programs of the student
  @GET('/listeProgrammes')
  Future<SignetsApiResponse<List<Program>>> getPrograms();

  /// Get the list of sessions
  @GET('/listeSessions')
  Future<SignetsApiResponse<List<Session>>> getSessionList();

  /// Get the course reviews (evaluations of the courses by the student) for the [session]
  @GET('/lireEvaluationCours')
  Future<SignetsApiResponse<List<CourseReview>>> getCourseReviews(@Query('session') String session);

  /// Get the courses activities of the [session]. [courseGroup] (ex: LOG430-01)
  /// filters the activities of a single course. [startDate] and [endDate]
  /// (format yyyy-MM-dd) limit the activities to this interval.
  @GET('/lireHoraireDesSeances')
  Future<SignetsApiResponse<List<CourseActivity>>> getCoursesActivities(
    @Query('session') String session, {
    @Query('coursGroupe') String? courseGroup,
    @Query('dateDebut') String? startDate,
    @Query('dateFin') String? endDate,
  });

  /// Get the weekly schedule and the teachers of the [session]
  @GET('/listeHoraireEtProf')
  Future<SignetsApiResponse<ScheduleAndTeachers>> getScheduleActivities(@Query('session') String session);

  /// Get the evaluations and the summary of the course [acronym]-[group] of the [session]
  @GET('/listeElementsEvaluation')
  Future<SignetsApiResponse<CourseSummary>> getCourseSummary(
    @Query('session') String session,
    @Query('sigle') String acronym,
    @Query('groupe') String group,
  );

  /// Get the replaced days of the [session]
  @GET('/lireJoursRemplaces')
  Future<SignetsApiResponse<List<ReplacedDay>>> getReplacedDays(@Query('session') String session);
}

extension SignetsApiResponseUnwrap<T> on SignetsApiResponse<T> {
  /// Throw an [ApiException] when Signets returned a blocking error.
  /// "No data" errors (ex: schedule not available yet) are not blocking.
  void throwIfError() {
    final message = error;
    if (message != null && message.isNotEmpty && !message.startsWith(SignetsError.scheduleNotAvailable)) {
      throw ApiException(prefix: SignetsClient.tagError, message: message);
    }
  }

  /// Return the data, or [fallback] when there is no data.
  /// Throw an [ApiException] when Signets returned a blocking error.
  T dataOr(T fallback) {
    throwIfError();
    return data ?? fallback;
  }

  /// Return the data. Throw an [ApiException] when Signets returned an error
  /// or no data.
  T requireData() {
    throwIfError();
    final value = data;
    if (value == null) {
      throw ApiException(prefix: SignetsClient.tagError, message: error ?? "No data returned");
    }
    return value;
  }
}
