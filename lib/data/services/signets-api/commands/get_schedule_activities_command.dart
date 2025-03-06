// Package imports:
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/signets-api/soap_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/utils/command.dart';

/// Call the SignetsAPI to get the courses activities for the [session] for
/// the student ([username]).
class GetScheduleActivitiesCommand implements Command<List<ScheduleActivity>> {
  final SignetsAPIClient client;
  final http.Client _httpClient;
  final RegExp _sessionShortNameRegExp;
  final String token;
  final String session;

  GetScheduleActivitiesCommand(
    this.client,
    this._httpClient,
    this._sessionShortNameRegExp, {
    required this.token,
    required this.session,
  });

  @override
  Future<List<ScheduleActivity>> execute() async {
    if (!_sessionShortNameRegExp.hasMatch(session)) {
      throw FormatException("Session $session isn't correctly formatted");
    }

    final queryParams = { "session" : session };
    final responseBody = await SoapService.sendSOAPRequest(
        _httpClient, Urls.listeHoraireEtProf, token, queryParameters: queryParams);

    /// Build and return the list of CourseActivity
    return responseBody
        .findAllElements("HoraireActivite")
        .map((node) => ScheduleActivity.fromXmlNode(node))
        .toList();
  }
}
