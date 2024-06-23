import 'package:http/http.dart' as http;
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';
import 'package:xml/xml.dart';

/// Call the SignetsAPI to get the list of all the [Session] for the student ([username]).
class GetSessionsCommand implements Command<List<Session>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;

  GetSessionsCommand(this.client, this._httpClient,
      {required this.username, required this.password});

  @override
  Future<List<Session>> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listSessionsOperation, username, password)
        .buildDocument();

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listSessionsOperation);

    /// Build and return the list of Session
    return responseBody
        .findAllElements("Trimestre")
        .map((node) => Session.fromXmlNode(node))
        .toList();
  }
}
