// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';

part 'signets_client.g.dart';

@RestApi(baseUrl: 'https://etsmobileapi.etsmtl.ca/api/Etudiant/')
abstract class SignetsClient {
  factory SignetsClient(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SignetsClient;

  /// Get the list of sessions
  @GET('/listeSessions')
  Future<SignetsApiResponse<List<Session>>> getSessionList();

  /// Get the schedule for a given session, course group, and date range
  /// [session] Short session (H2025, E2025, A2025), long session (Hiver 2025, Été 2025, Automne 2025), or digital session (20251, 20252, 20253).
  /// [courseGroup] Group courses in the acronym-group format, for example CHM131-01. If not specified, retrieves all group courses. 
  /// [startDate] Start date in the format YYYY-MM-DD. If not specified, retrieves all courses from the beginning of the session.
  /// [endDate] End date in the format YYYY-MM-DD. If not specified, retrieves all courses until the end of the session.
  @GET('/lireHoraireDesSeances')
  Future<SignetsApiResponse<List<CourseActivity>>> getSchedule(
    @Query('session') String session,
    @Query('coursGroupe') String? courseGroup,
    @Query('dateDebut') DateTime? startDate, 
    @Query('dateFin') DateTime? endDate);
}
