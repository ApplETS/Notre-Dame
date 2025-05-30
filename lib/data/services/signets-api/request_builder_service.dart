// Package imports:
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/signets-api/models/signets_errors.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/utils/api_exception.dart';
import '../../../locator.dart';

mixin RequestBuilderService {
  static const String tag = "RequestBuilderService";
  static const String tagError = "$tag - Error";
  static const int maxRetry = 3;
  static int retries = 0;

  /// Build the basic headers for a SOAP request on.
  static Map<String, String> _buildHeaders(String token) => {
    "Accept": "application/xml",
    "Authorization": "Bearer $token",
  };

  /// Send a GET request to SignetsAPI using queryParameters then return
  /// the response.
  /// Will throw a [ApiException] if an error is returned by the api.
  static Future<XmlElement> sendRequest(
    http.Client client,
    String endpoint,
    String token,
    String resultTag, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(Urls.signetsAPI, endpoint, queryParameters);
    final response = await client.get(uri, headers: _buildHeaders(token));

    if (response.statusCode == StatusCodes.UNAUTHORIZED) {
      RequestBuilderService.retries++;
      if (retries > maxRetry) {
        retries = 0;
        throw ApiException(
          prefix: tagError,
          message: "Token invalide. Veuillez vous déconnecter et vous reconnecter."
        );
      }

      final authService = locator<AuthService>();
      final tokenResult = await authService.acquireTokenSilent();
      
      if (tokenResult.$1 == null) {
        retries = 0;
        throw ApiException(
          prefix: tagError,
          message: "Session expirée. Veuillez vous reconnecter."
        );
      }

      return await sendRequest(
        client,
        endpoint,
        await authService.getToken(),
        resultTag,
        queryParameters: queryParameters,
      );
    }
    retries = 0;

    final responseBody = XmlDocument.parse(response.body).findAllElements(resultTag).first;

    // Throw exception if the error tag contains a blocking error
    if (responseBody.findElements(SignetsError.signetsErrorSoapTag).isNotEmpty &&
        responseBody.findElements(SignetsError.signetsErrorSoapTag).first.innerText.isNotEmpty) {
      final errorMessage = responseBody.findElements(SignetsError.signetsErrorSoapTag).first.innerText;
      if (!errorMessage.startsWith(SignetsError.scheduleNotAvailable)) {
        throw ApiException(
          prefix: tagError,
          message: responseBody.findElements(SignetsError.signetsErrorSoapTag).first.innerText,
        );
      } else {
        return responseBody;
      }
    }

    return responseBody;
  }
}
