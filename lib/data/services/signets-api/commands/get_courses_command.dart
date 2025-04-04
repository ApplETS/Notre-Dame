// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses of the student ([username]).
class GetCoursesCommand implements Command<List<Course>> {
  static const String endpoint = "/api/Etudiant/listeCours";
  static const String responseTag = "ListeCours";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetCoursesCommand(this.client, this._httpClient, {required this.token});

  @override
  Future<List<Course>> execute() async {
    // Generate initial soap envelope
    final responseBody = await RequestBuilderService.sendRequest(_httpClient, endpoint, token, responseTag);

    return responseBody.findAllElements("Cours").map((node) => Course.fromXmlNode(node)).toList();
  }
}
