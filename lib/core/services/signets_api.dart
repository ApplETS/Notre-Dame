// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:notredame/core/models/schedule_activity.dart';
import 'package:xml/xml.dart';

// CONSTANTS & EXCEPTIONS
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/utils/api_exception.dart';
import 'package:notredame/core/constants/signets_errors.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';

class SignetsApi {
  static const String tag = "SignetsApi";
  static const String tagError = "$tag - Error";

  http.Client _client;

  final String _signetsErrorTag = "erreur";

  /// Expression to validate the format of a session short name (ex: A2020)
  final RegExp _sessionShortNameRegExp = RegExp("^([A-É-H][0-9]{4})");

  /// Expression to validate the format of a course (ex: MAT256-01)
  final RegExp _courseGroupRegExp = RegExp("^([A-Z]{3}[0-9]{3}-[0-9]{2})");

  SignetsApi({http.Client client}) {
    if (client == null) {
      _signetsClient();
    } else {
      _client = client;
    }
  }

  /// Call the SignetsAPI to get the courses activities for the [session] for
  /// the student ([username]). By specifying [courseGroup] we can filter the
  /// results to get only the activities for this course.
  /// If the [startDate] and/or [endDate] are specified the results will contains
  /// all the activities between these dates.
  Future<List<CourseActivity>> getCoursesActivities(
      {@required String username,
      @required String password,
      @required String session,
      String courseGroup = "",
      DateTime startDate,
      DateTime endDate}) async {
    // Validate the format of parameters
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't a correctly formatted");
    }
    if (courseGroup.isNotEmpty && !_courseGroupRegExp.hasMatch(courseGroup)) {
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

    // Add the parameters needed inside the request.
    body
        .findAllElements(Urls.listClassScheduleOperation,
            namespace: Urls.signetsOperationBase)
        .first
        .children
        .add(operationContent.buildFragment());

    final responseBody =
        await _sendSOAPRequest(body, Urls.listClassScheduleOperation);

    /// Build and return the list of CourseActivity
    return responseBody
        .findAllElements("Seances")
        .map((node) => CourseActivity.fromXmlNode(node))
        .toList();
  }

  /// Call the SignetsAPI to get the courses activities for the [session] for
  /// the student ([username]).
  Future<List<ScheduleActivity>> getScheduleActivities(
      {@required String username,
      @required String password,
      @required String session}) async {
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't correctly formatted");
    }

    // Generate initial soap envelope
    final body = buildBasicSOAPBody(Urls.listeHoraireEtProf, username, password)
        .buildDocument();
    final operationContent = XmlBuilder();

    // Add the content needed by the operation
    operationContent.element("pSession", nest: () {
      operationContent.text(session);
    });

    // Add the parameters needed inside the request.
    body
        .findAllElements(Urls.listeHoraireEtProf,
            namespace: Urls.signetsOperationBase)
        .first
        .children
        .add(operationContent.buildFragment());

    final responseBody = await _sendSOAPRequest(body, Urls.listeHoraireEtProf);

    /// Build and return the list of CourseActivity
    return responseBody
        .findAllElements("HoraireActivite")
        .map((node) => ScheduleActivity.fromXmlNode(node))
        .toList();
  }

  /// Call the SignetsAPI to get the courses of the student ([username]).
  Future<List<Course>> getCourses(
      {@required String username, @required String password}) async {
    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.listCourseOperation, username, password)
            .buildDocument();

    final responseBody = await _sendSOAPRequest(body, Urls.listCourseOperation);

    return responseBody
        .findAllElements("Cours")
        .map((node) => Course.fromXmlNode(node))
        .toList();
  }

  /// Call the SignetsAPI to get all the evaluations (exams) and the summary
  /// of [course] for the student ([username]).
  Future<CourseSummary> getCourseSummary(
      {@required String username,
      @required String password,
      @required Course course}) async {
    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.listEvaluationsOperation, username, password)
            .buildDocument();
    final operationContent = XmlBuilder();

    // Add the content needed by the operation
    operationContent.element("pSigle", nest: () {
      operationContent.text(course.acronym);
    });
    operationContent.element("pGroupe", nest: () {
      operationContent.text(course.group);
    });
    operationContent.element("pSession", nest: () {
      operationContent.text(course.session);
    });

    body
        .findAllElements(Urls.listEvaluationsOperation,
            namespace: Urls.signetsOperationBase)
        .first
        .children
        .add(operationContent.buildFragment());

    final responseBody =
        await _sendSOAPRequest(body, Urls.listEvaluationsOperation);
    if (responseBody
            .getElement(_signetsErrorTag)
            .innerText
            .contains(SignetsError.gradesNotAvailable) ||
        responseBody.findAllElements('ElementEvaluation').isEmpty) {
      throw const ApiException(
          prefix: tag,
          message: "No grades available",
          errorCode: SignetsError.gradesEmpty);
    }

    return CourseSummary.fromXmlNode(responseBody);
  }

  /// Call the SignetsAPI to get the list of all the [Session] for the student ([username]).
  Future<List<Session>> getSessions(
      {@required String username, @required String password}) async {
    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.listSessionsOperation, username, password)
            .buildDocument();

    final responseBody =
        await _sendSOAPRequest(body, Urls.listSessionsOperation);

    /// Build and return the list of Session
    return responseBody
        .findAllElements("Trimestre")
        .map((node) => Session.fromXmlNode(node))
        .toList();
  }

  /// Call the SignetsAPI to get the [ProfileStudent] for the student ([username]).
  Future<ProfileStudent> getStudentInfo(
      {@required String username, @required String password}) async {
    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.infoStudentOperation, username, password)
            .buildDocument();

    final responseBody =
        await _sendSOAPRequest(body, Urls.infoStudentOperation);

    // Build and return the info
    return ProfileStudent.fromXmlNode(responseBody);
  }

  /// Call the SignetsAPI to get the list of all the [Program] for the student ([username]).
  Future<List<Program>> getPrograms(
      {@required String username, @required String password}) async {
    // Generate initial soap envelope
    final body =
        buildBasicSOAPBody(Urls.listProgramsOperation, username, password)
            .buildDocument();

    final responseBody =
        await _sendSOAPRequest(body, Urls.listProgramsOperation);

    /// Build and return the list of Program
    return responseBody
        .findAllElements("Programme")
        .map((node) => Program.fromXmlNode(node))
        .toList();
  }

  /// Build the basic headers for a SOAP request on.
  Map<String, String> _buildHeaders(String soapAction) =>
      {"Content-Type": "text/xml", "SOAPAction": soapAction};

  String _operationResponseTag(String operation) => "${operation}Result";

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

  /// Send a SOAP request to SignetsAPI using [body] as envelope then return
  /// the response.
  /// Will throw a [ApiException] if an error is returned by the api.
  Future<XmlElement> _sendSOAPRequest(
      XmlDocument body, String operation) async {
    // Send the envelope
    final response = await _client.post(Uri.parse(Urls.signetsAPI),
        headers: _buildHeaders(Urls.signetsOperationBase + operation),
        body: body.toXmlString());

    final responseBody = XmlDocument.parse(response.body)
        .findAllElements(_operationResponseTag(operation))
        .first;

    // Throw exception if the error tag contains a blocking error
    if (responseBody
        .findElements(_signetsErrorTag)
        .first
        .innerText
        .isNotEmpty) {
      switch (responseBody.findElements(_signetsErrorTag).first.innerText) {
        case SignetsError.scheduleNotAvailable:
        case SignetsError.scheduleNotAvailableF:
          // Don't do anything.
          break;
        case SignetsError.credentialsInvalid:
        default:
          throw ApiException(
              prefix: tagError,
              message:
                  responseBody.findElements(_signetsErrorTag).first.innerText);
      }
    }

    return responseBody;
  }

  /// Create a [http.Client] with the certificate to access the SignetsAPI
  Future _signetsClient() async {
    final ByteData data =
        await rootBundle.load("assets/certificates/signets_cert.crt");
    final securityContext = SecurityContext()
      ..setTrustedCertificatesBytes(data.buffer.asUint8List());

    final ioClient = HttpClient(context: securityContext);

    _client = IOClient(ioClient);
  }
}
