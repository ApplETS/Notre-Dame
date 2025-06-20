// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the replaced days for the [session]
/// of the student ([username]).
class GetReplacedDaysCommand implements Command<List<ReplacedDay>> {
  static const String endpoint = "/api/Etudiant/lireJoursRemplaces";
  static const String responseTag = "ListeJoursRemplaces";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;
  final String session;

  GetReplacedDaysCommand(this.client, this._httpClient, {required this.token, required this.session});

  @override
  Future<List<ReplacedDay>> execute() async {
    final queryParams = {"session": session};
    final responseBody = await RequestBuilderService.sendRequest(
      _httpClient,
      endpoint,
      token,
      responseTag,
      queryParameters: queryParams,
    );
    return responseBody.findAllElements("JourRemplace").map((node) => ReplacedDay.fromXmlNode(node)).toList();
  }
}
