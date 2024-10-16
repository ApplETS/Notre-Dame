// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses of the student ([username]).
class GetCoursesCommand implements Command<List<Course>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;

  GetCoursesCommand(this.client, this._httpClient,
      {required this.username, required this.password});

  @override
  Future<List<Course>> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listCourseOperation, username, password)
        .buildDocument();

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listCourseOperation);

    return responseBody
        .findAllElements("Cours")
        .map((node) => Course.fromXmlNode(node))
        .toList();
  }
}
