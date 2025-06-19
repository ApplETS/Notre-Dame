// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the replaced days of a session ([username]).
class GetReplacedDaysCommand implements Command<List<Course>> {
  static const String endpoint = "/api/Etudiant/lireJoursRemplaces";
  static const String responseTag = "ListeJoursRemplaces";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetReplacedDaysCommand(this.client, this._httpClient, {required this.token});

  @override
  Future<List<Course>> execute() async {
    final queryParams = {"session": "E2025"};
    final responseBody = await RequestBuilderService.sendRequest(
      _httpClient,
      endpoint,
      token,
      responseTag,
      queryParameters: queryParams,
    );
    return responseBody.findAllElements("JourRemplace").map((node) => Course.fromXmlNode(node)).toList();
  }
}
