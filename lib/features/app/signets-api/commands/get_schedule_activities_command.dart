// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/signets-api/soap_service.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses activities for the [session] for
/// the student ([username]).
class GetScheduleActivitiesCommand implements Command<List<ScheduleActivity>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final RegExp _sessionShortNameRegExp;
  final String username;
  final String password;
  final String session;

  GetScheduleActivitiesCommand(
    this.client,
    this._httpClient,
    this._sessionShortNameRegExp, {
    required this.username,
    required this.password,
    required this.session,
  });

  @override
  Future<List<ScheduleActivity>> execute() async {
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't correctly formatted");
    }

    // Generate initial soap envelope
    final body = SoapService.buildBasicSOAPBody(
            Urls.listeHoraireEtProf, username, password)
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

    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, body, Urls.listeHoraireEtProf);

    /// Build and return the list of CourseActivity
    return responseBody
        .findAllElements("HoraireActivite")
        .map((node) => ScheduleActivity.fromXmlNode(node))
        .toList();
  }
}
