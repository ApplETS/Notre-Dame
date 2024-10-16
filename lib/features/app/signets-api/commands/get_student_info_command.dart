// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/profile_student.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the [ProfileStudent] for the student.
class GetStudentInfoCommand implements Command<ProfileStudent> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;

  GetStudentInfoCommand(this.client, this._httpClient,
      {required this.username, required this.password});

  @override
  Future<ProfileStudent> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.infoStudentOperation, username, password)
        .buildDocument();

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.infoStudentOperation);

    // Build and return the info
    return ProfileStudent.fromXmlNode(responseBody);
  }
}
