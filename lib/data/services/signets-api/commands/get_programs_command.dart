// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the list of all the [Program] for the student ([username]).
class GetProgramsCommand implements Command<List<Program>> {
  static const String endpoint = "/api/Etudiant/listeProgrammes";
  static const String responseTag = "ListeProgrammes";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetProgramsCommand(this.client, this._httpClient,
      {required this.token});

  @override
  Future<List<Program>> execute() async {
    final responseBody = await RequestBuilderService.sendRequest(
        _httpClient, endpoint, token, responseTag);

    /// Build and return the list of Program
    return responseBody
        .findAllElements("Programme")
        .map((node) => Program.fromXmlNode(node))
        .toList();
  }
}
