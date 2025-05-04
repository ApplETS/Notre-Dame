import 'package:dio/dio.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:retrofit/retrofit.dart';

part 'signets_client.g.dart';

@RestApi(baseUrl: 'https://etsmobileapi.etsmtl.ca/api/Etudiant/')
abstract class SignetsClient {
  factory SignetsClient(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _SignetsClient;

  /// Get the list of sessions
  @GET('/listeSessions')
  Future<SignetsApiResponse<List<Session>>> getSessionList(); 
}