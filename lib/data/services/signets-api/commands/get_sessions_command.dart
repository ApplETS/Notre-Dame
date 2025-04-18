// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the list of all the [Session] for the student ([username]).
class GetSessionsCommand implements Command<List<Session>> {
  static const String endpoint = "/api/Etudiant/listeSessions";
  static const String responseTag = "ListeSessions";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetSessionsCommand(this.client, this._httpClient, {required this.token});

  @override
  Future<List<Session>> execute() async {
    final responseBody = await RequestBuilderService.sendRequest(_httpClient, endpoint, token, responseTag);

    /// Build and return the list of Session
    return responseBody.findAllElements("Session").map((node) => Session.fromXmlNode(node)).toList();
  }
}
