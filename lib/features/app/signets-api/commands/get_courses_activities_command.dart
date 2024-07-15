// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses activities for the [session] for
/// the student ([username]). By specifying [courseGroup] we can filter the
/// results to get only the activities for this course.
/// If the [startDate] and/or [endDate] are specified the results will contains
/// all the activities between these dates
class GetCoursesActivitiesCommand implements Command<List<CourseActivity>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final RegExp _sessionShortNameRegExp;
  final RegExp _courseGroupRegExp;
  final String username;
  final String password;
  final String session;
  final String courseGroup;
  final DateTime? startDate;
  final DateTime? endDate;

  GetCoursesActivitiesCommand(
    this.client,
    this._httpClient,
    this._sessionShortNameRegExp,
    this._courseGroupRegExp, {
    required this.username,
    required this.password,
    required this.session,
    this.courseGroup = "",
    this.startDate,
    this.endDate,
  });

  @override
  Future<List<CourseActivity>> execute() async {
    // Validate the format of parameters
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't a correctly formatted");
    }
    if (courseGroup.isNotEmpty && !_courseGroupRegExp.hasMatch(courseGroup)) {
      throw FormatException(
          "CourseGroup $courseGroup isn't a correctly formatted");
    }
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      throw ArgumentError("The startDate can't be after endDate.");
    }

    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listClassScheduleOperation, username, password)
        .buildDocument();
    final operationContent = XmlBuilder();

    // Add the content needed by the operation
    operationContent.element("pSession", nest: () {
      operationContent.text(session);
    });
    operationContent.element("pCoursGroupe", nest: () {
      operationContent.text(courseGroup);
    });

    operationContent.element("pDateDebut", nest: () {
      operationContent.text(startDate == null
          ? ""
          : "${startDate!.year}-${startDate!.month}-${startDate!.day}");
    });
    operationContent.element("pDateFin", nest: () {
      operationContent.text(endDate == null
          ? ""
          : "${endDate!.year}-${endDate!.month}-${endDate!.day}");
    });

    // Add the parameters needed inside the request.
    body
        .findAllElements(Urls.listClassScheduleOperation,
            namespace: Urls.signetsOperationBase)
        .first
        .children
        .add(operationContent.buildFragment());

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listClassScheduleOperation);

    /// Build and return the list of CourseActivity
    return responseBody
        .findAllElements("Seances")
        .map((node) => CourseActivity.fromXmlNode(node))
        .toList();
  }
}
