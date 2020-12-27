// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:xml/xml.dart';

// CONSTANTS & EXCEPTIONS
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/utils/api_exception.dart';

// MODEL
import 'package:notredame/core/models/class_session.dart';

class SignetsApi {
  static const String tag = "SignetsApi";
  static const String tagError = "$tag - Error";

  final http.Client _client;

  final String _signetsErrorTag = "erreur";

  /// Expression to validate the format of a session short name (ex: A2020)
  final RegExp sessionShortNameRegExp = RegExp("^([A-E-H][0-9]{4})");

  /// Expression to validate the format of a course (ex: MAT256-01)
  final RegExp courseGroupRegExp = RegExp("^([A-Z]{3}[0-9]{3}-[0-9]{2})");

  SignetsApi({http.Client client}) : _client = client ?? _signetsClient();

  Future<List<ClassSession>> getClassSessions(
      {@required String username,
      @required String password,
      @required String session,
      String courseGroup = "",
      DateTime startDate,
      DateTime endDate}) async {
    // Validate the format of parameters
    if (!sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't a correctly formatted");
    }
    if (courseGroup.isNotEmpty && !courseGroupRegExp.hasMatch(courseGroup)) {
      throw FormatException(
          "CourseGroup $courseGroup isn't a correctly formatted");
    }
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ArgumentError("The startDate can't be after endDate.");
    }

    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.listClassScheduleOperation, username, password)
            .buildDocument();
    final operationContent = XmlBuilder();

    // Add the content needed by the operation
    operationContent.element("pSession", nest: () {
      operationContent.text(session);
    });
    operationContent.element("pCoursGroupe", nest: () {
      operationContent.text(courseGroup ?? "");
    });

    operationContent.element("pDateDebut", nest: () {
      operationContent.text(startDate == null
          ? ""
          : "${startDate.year}-${startDate.month}-${startDate.day}");
    });
    operationContent.element("pDateFin", nest: () {
      operationContent.text(endDate == null
          ? ""
          : "${endDate.year}-${endDate.month}-${endDate.day}");
    });

    body
        .findAllElements(Urls.listClassScheduleOperation,
            namespace: Urls.signetsOperationBase)
        .first
        .children
        .add(operationContent.buildFragment());

    // Send the envelope
    final response = await _client.post(Urls.signetsAPI,
        headers: _buildHeaders(
            Urls.signetsOperationBase + Urls.listClassScheduleOperation),
        body: body.toXmlString());

    final responseBody = XmlDocument.parse(response.body)
        .findAllElements(_operationResponseTag(Urls.listClassScheduleOperation))
        .first;

    // Throw exception if the error tag is not empty
    if (responseBody
        .findElements(_signetsErrorTag)
        .first
        .innerText
        .isNotEmpty) {
      throw ApiException(
          prefix: tagError,
          message: responseBody.findElements(_signetsErrorTag).first.innerText);
    }

    /// Build and return the list of ClassSession
    return XmlDocument.parse(response.body)
        .findAllElements("Seances")
        .map((node) => ClassSession.fromXmlNode(node)).toList();
  }

  /// Build the basic headers for a SOAP request on.
  Map<String, String> _buildHeaders(String soapAction) =>
      {"Content-Type": "text/xml", "SOAPAction": soapAction};

  String _operationResponseTag(String operation) => "${operation}Response";

  /// Build the default body for communicate with the SignetsAPI.
  /// [firstElementName] should be the SOAP operation of the request.
  @visibleForTesting
  XmlBuilder buildBasicSOAPBody(
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

  /// Create a [http.Client] with the certificate to access the SignetsAPI
  static http.Client _signetsClient() {
    final securityContext = SecurityContext()
      ..setTrustedCertificates("assets/certificates/signets_cert.crt");

    final ioClient = HttpClient(context: securityContext);

    return IOClient(ioClient);
  }
}
