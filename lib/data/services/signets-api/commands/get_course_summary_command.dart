// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/data/services/signets-api/models/signets_errors.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/api_exception.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get all the evaluations (exams) and the summary
/// of [course] for the student ([username]).
class GetCourseSummaryCommand implements Command<CourseSummary> {
  static const String endpoint = "/api/Etudiant/listeElementsEvaluation";
  static const String responseTag = "ListeElementsEvaluation";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;
  final String session;
  final String acronym;
  final String group;

  GetCourseSummaryCommand(
    this.client,
    this._httpClient, {
    required this.token,
    required this.session,
    required this.acronym,
    required this.group,
  });

  @override
  Future<CourseSummary> execute() async {
    final queryParams = {"session": session, "sigle": acronym, "groupe": group};

    final responseBody = await RequestBuilderService.sendRequest(
        _httpClient, endpoint, token, responseTag,
        queryParameters: queryParams);

    final errorTag = responseBody.getElement(SignetsError.signetsErrorSoapTag);
    if (errorTag != null &&
            errorTag.innerText.contains(SignetsError.gradesNotAvailable) ||
        responseBody.findAllElements('ElementEvaluation').isEmpty) {
      throw const ApiException(
          prefix: SignetsAPIClient.tag,
          message: "No grades available",
          errorCode: SignetsError.gradesEmpty);
    }

    return CourseSummary.fromXmlNode(responseBody);
  }
}
