// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the list of all [CourseReview] for the [session]
/// of the student ([username]).
class GetCourseReviewsCommand implements Command<List<CourseReview>> {
  static const String endpoint = "/api/Etudiant/lireEvaluationCours";
  static const String responseTag = "ListeEvaluationsCours";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;
  final String session;

  GetCourseReviewsCommand(
    this.client,
    this._httpClient, {
    required this.token,
    required this.session,
  });

  @override
  Future<List<CourseReview>> execute() async {
    final queryParams = { "session": session };

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, endpoint, token, responseTag, queryParameters: queryParams);

    /// Build and return the list of Program
    return responseBody
        .findAllElements("EvaluationCours")
        .map((node) => CourseReview.fromXmlNode(node))
        .toList();
  }
}
