// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/request_builder_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the [ProfileStudent] for the student.
class GetStudentInfoCommand implements Command<ProfileStudent> {
  static const String endpoint = "/api/Etudiant/infoEtudiant";
  static const String responseTag = "Etudiant";

  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String token;

  GetStudentInfoCommand(this.client, this._httpClient, {required this.token});

  @override
  Future<ProfileStudent> execute() async {
    final responseBody = await RequestBuilderService.sendRequest(
        _httpClient, endpoint, token, responseTag);

    // Build and return the info
    return ProfileStudent.fromXmlNode(responseBody);
  }
}
