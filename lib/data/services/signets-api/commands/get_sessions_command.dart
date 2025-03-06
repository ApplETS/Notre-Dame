// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/signets-api/soap_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the list of all the [Session] for the student ([username]).
class GetSessionsCommand implements Command<List<Session>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetSessionsCommand(this.client, this._httpClient, {required this.token});

  @override
  Future<List<Session>> execute() async {
    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, Urls.listSessionsOperation, token);

    /// Build and return the list of Session
    return responseBody
        .findAllElements("Trimestre")
        .map((node) => Session.fromXmlNode(node))
        .toList();
  }
}
