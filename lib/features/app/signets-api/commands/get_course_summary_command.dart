import 'package:http/http.dart' as http;
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_summary.dart';
import 'package:notredame/features/app/signets-api/models/signets_errors.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/api_exception.dart';
import 'package:notredame/utils/command.dart';
import 'package:xml/xml.dart';

/// Call the SignetsAPI to get all the evaluations (exams) and the summary
/// of [course] for the student ([username]).
class GetCourseSummaryCommand implements Command<CourseSummary> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final String username;
  final String password;
  final Course course;

  GetCourseSummaryCommand(
    this.client,
    this._httpClient, {
    required this.username,
    required this.password,
    required this.course,
  });

  @override
  Future<CourseSummary> execute() async {
    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listEvaluationsOperation, username, password)
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

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listEvaluationsOperation);
    final errorTag = responseBody.getElement(SignetsError.signetsErrorSoapTag);
    if (errorTag != null &&
            errorTag.innerText.contains(SignetsError.gradesNotAvailable) ||
        responseBody.findAllElements('ElementEvaluation').isEmpty) {
      throw const ApiException(
          prefix: SignetsAPIClient.tag,
          message: "No grades available",
          errorCode: SignetsError.gradesEmpty);
    }

    return CourseSummary.fromXmlNode(responseBody);
  }
}
