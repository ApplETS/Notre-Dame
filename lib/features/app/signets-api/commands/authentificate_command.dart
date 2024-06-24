// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Returns whether the user is logged in or not throught the SignetsAPI.
class AuthenticateCommand implements Command<bool> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;

  AuthenticateCommand(this.client, this._httpClient,
      {required this.username, required this.password});

  @override
  Future<bool> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.donneesAuthentificationValides, username, password)
        .buildDocument();
    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.donneesAuthentificationValides);

    /// Build and return the authentication status
    return responseBody.innerText == "true";
  }
}
