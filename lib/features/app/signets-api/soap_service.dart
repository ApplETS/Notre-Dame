import 'package:notredame/constants/urls.dart';
import 'package:notredame/utils/api_exception.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import 'package:notredame/features/app/signets-api/models/signets_errors.dart';

mixin SoapService {
  static const String tag = "SoapService";
  static const String tagError = "$tag - Error";

  /// Build the default body for communicate with the SignetsAPI.
  /// [firstElementName] should be the SOAP operation of the request.
  static XmlBuilder buildBasicSOAPBody(
      String firstElementName, String username, String password) {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element("soap:Envelope", namespaces: {
      "http://www.w3.org/2001/XMLSchema-instance": "xsi",
      "http://www.w3.org/2001/XMLSchema": "xsd",
      "http://schemas.xmlsoap.org/soap/envelope/": "soap"
    }, nest: () {
      builder.element("soap:Body", nest: () {
        // Details of the envelope
        builder.element(firstElementName, nest: () {
          builder.namespace(Urls.signetsOperationBase);
          builder.element("codeAccesUniversel", nest: username);
          builder.element("motPasse", nest: password);
        });
      });
    });

    return builder;
  }

  /// Build the basic headers for a SOAP request on.
  static Map<String, String> _buildHeaders(String soapAction) =>
      {"Content-Type": "text/xml", "SOAPAction": soapAction};

  static String _operationResponseTag(String operation) => "${operation}Result";

  /// Send a SOAP request to SignetsAPI using [body] as envelope then return
  /// the response.
  /// Will throw a [ApiException] if an error is returned by the api.
  static Future<XmlElement> sendSOAPRequest(
      http.Client client, XmlDocument body, String operation) async {
    // Send the envelope
    final response = await client.post(Uri.parse(Urls.signetsAPI),
        headers: _buildHeaders(Urls.signetsOperationBase + operation),
        body: body.toXmlString());

    final responseBody = XmlDocument.parse(response.body)
        .findAllElements(_operationResponseTag(operation))
        .first;

    // Throw exception if the error tag contains a blocking error
    if (responseBody
            .findElements(SignetsError.signetsErrorSoapTag)
            .isNotEmpty &&
        responseBody
            .findElements(SignetsError.signetsErrorSoapTag)
            .first
            .innerText
            .isNotEmpty) {
      switch (responseBody
          .findElements(SignetsError.signetsErrorSoapTag)
          .first
          .innerText) {
        case SignetsError.scheduleNotAvailable:
        case SignetsError.scheduleNotAvailableF:
          // Don't do anything.
          break;
        case SignetsError.credentialsInvalid:
        default:
          throw ApiException(
              prefix: tagError,
              message: responseBody
                  .findElements(SignetsError.signetsErrorSoapTag)
                  .first
                  .innerText);
      }
    }

    return responseBody;
  }
}
