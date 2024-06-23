import 'package:http/http.dart' as http;
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/program.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';
import 'package:xml/xml.dart';

/// Call the SignetsAPI to get the list of all the [Program] for the student ([username]).
class GetProgramsCommand implements Command<List<Program>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;

  GetProgramsCommand(this.client, this._httpClient,
      {required this.username, required this.password});

  @override
  Future<List<Program>> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listProgramsOperation, username, password)
        .buildDocument();

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listProgramsOperation);

    /// Build and return the list of Program
    return responseBody
        .findAllElements("Programme")
        .map((node) => Program.fromXmlNode(node))
        .toList();
  }
}
