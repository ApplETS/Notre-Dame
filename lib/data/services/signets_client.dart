import 'package:dio/dio.dart';
import 'package:notredame/data/models/signets-api/signets_api_response.dart';
import 'package:notredame/data/models/signets-api/session.dart';
import 'package:retrofit/retrofit.dart';

part 'signets_client.g.dart';

@RestApi(baseUrl: 'https://etsmobileapi.etsmtl.ca/api/Etudiant/')
abstract class SignetsClient {
  factory SignetsClient(Dio dio, String authToken, {String? baseUrl, ParseErrorLogger? errorLogger}) {
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    return _SignetsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  /// Get the list of sessions
  @GET('/listeSessions')
  Future<SignetsApiResponse<List<Session>>> getSessionList(); 
}