// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';

// CONSTANTS
import 'package:notredame/core/constants/urls.dart';
import 'package:notredame/core/utils/api_exception.dart';

// MOCKS
import '../mock/services/http_client_mock.dart';

void main() {
  HttpClientMock clientMock;
  SignetsApi service;

  group('SignetsApi - ', () {
    setUp(() {
      clientMock = HttpClientMock();
      service = SignetsApi(client: clientMock);
    });

    tearDown(() {
      // Clear the mock and all interactions not already processed
      clientMock.close();
      clearInteractions(clientMock);
      reset(clientMock);
    });

    test('buildBasicSoapBody - contains all basic element', () {
      const String username = "username";
      const String password = "password";

      // ignore: missing_whitespace_between_adjacent_strings
      const expectedResult = '<?xml version="1.0" encoding="utf-8"?>'
          // ignore: missing_whitespace_between_adjacent_strings
          '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
          '<soap:Body>'
          // ignore: missing_whitespace_between_adjacent_strings
          '<testOperation xmlns="http://etsmtl.ca/">'
          '<codeAccesUniversel>username</codeAccesUniversel>'
          '<motPasse>password</motPasse>'
          '</testOperation>'
          '</soap:Body>'
          '</soap:Envelope>';

      final result =
          service.buildBasicSOAPBody("testOperation", username, password);

      expect(result.buildDocument().toString(), expectedResult);
    });

    group("getCoursesActivities - ", () {
      const String courseActivityXML = '<Seances>'
          '<dateDebut>2020-09-03T18:00:00</dateDebut> '
          '<dateFin>2020-09-03T20:00:00</dateFin> '
          '<coursGroupe>GEN101-01</coursGroupe> '
          '<nomActivite>TP</nomActivite> '
          '<local>À distance</local> '
          '<descriptionActivite>Travaux pratiques</descriptionActivite> '
          '<libelleCours>Libelle du cours</libelleCours> '
          '</Seances>';

      final CourseActivity courseActivity = CourseActivity(
          courseGroup: 'GEN101-01',
          courseName: 'Libelle du cours',
          activityName: 'TP',
          activityDescription: 'Travaux pratiques',
          activityLocation: 'À distance',
          startDateTime: DateTime(2020, 9, 3, 18),
          endDateTime: DateTime(2020, 9, 3, 20));

      test("right credentials and valid parameters", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildResponse(
            Urls.listClassScheduleOperation,
            courseActivityXML + courseActivityXML,
            'ListeDesSeances');

        HttpClientMock.stubPost(clientMock, Urls.signetsAPI, stubResponse);

        final result = await service.getCoursesActivities(
            username: username, password: password, session: session);

        expect(result, isA<List<CourseActivity>>());
        expect(result.first == courseActivity, isTrue);
        expect(result.length, 2);
      });

      group("invalid parameters - ", () {
        test("session", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A202";

          expect(
              service.getCoursesActivities(
                  username: username, password: password, session: session),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "The session should validate the regex: /^([A-E-H][0-9]{4})/");
        });

        test("courseGroup", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A2020";
          const String courseGroup1 = "MA123-01";
          const String courseGroup2 = "MAT12-01";
          const String courseGroup3 = "MAT12301";
          const String courseGroup4 = "MAT123-1";

          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup1),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup2),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup3),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup4),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
        });

        test("startDate is after endDate", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A2020";

          final DateTime startDate = DateTime(2020, 2);
          final DateTime endDate = DateTime(2020);

          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  startDate: startDate,
                  endDate: endDate),
              throwsArgumentError,
              reason: "The startDate should be before the endDate");
        });
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(
            Urls.listClassScheduleOperation,
            'An error occurred',
            'ListeDesSeances');

        HttpClientMock.stubPost(clientMock, Urls.signetsAPI, stubResponse);

        expect(
            service.getCoursesActivities(
                username: username, password: password, session: session),
            throwsA(isInstanceOf<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getSessions - ", () {
      const String sessionXML = '<Trimestre>'
          '<abrege>H2018</abrege>'
          '<auLong>Hiver 2018</auLong> '
          '<dateDebut>2018-01-04</dateDebut>'
          '<dateFin>2018-04-23</dateFin>'
          '<dateFinCours>2018-04-11</dateFinCours>'
          '<dateDebutChemiNot>2017-10-30</dateDebutChemiNot>'
          '<dateFinChemiNot>2017-11-14</dateFinChemiNot>'
          '<dateDebutAnnulationAvecRemboursement>2018-01-04</dateDebutAnnulationAvecRemboursement>'
          '<dateFinAnnulationAvecRemboursement>2018-01-17</dateFinAnnulationAvecRemboursement>'
          '<dateFinAnnulationAvecRemboursementNouveauxEtudiants>2018-01-31</dateFinAnnulationAvecRemboursementNouveauxEtudiants>'
          '<dateDebutAnnulationSansRemboursementNouveauxEtudiants>2018-02-01</dateDebutAnnulationSansRemboursementNouveauxEtudiants>'
          '<dateFinAnnulationSansRemboursementNouveauxEtudiants>2018-03-14</dateFinAnnulationSansRemboursementNouveauxEtudiants>'
          '<dateLimitePourAnnulerASEQ>2018-01-31</dateLimitePourAnnulerASEQ>'
          '</Trimestre>';

      final Session session = Session(
          shortName: 'H2018',
          name: 'Hiver 2018',
          startDate: DateTime(2018, 1, 4),
          endDate: DateTime(2018, 4, 23),
          endDateCourses: DateTime(2018, 4, 11),
          startDateRegistration: DateTime(2017, 10, 30),
          deadlineRegistration: DateTime(2017, 11, 14),
          startDateCancellationWithRefund: DateTime(2018, 1, 4),
          deadlineCancellationWithRefund: DateTime(2018, 1, 17),
          deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
          startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
          deadlineCancellationASEQ: DateTime(2018, 1, 31));

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildResponse(
            Urls.listSessionsOperation, sessionXML + sessionXML, 'liste');

        HttpClientMock.stubPost(clientMock, Urls.signetsAPI, stubResponse);

        final result = await service.getSessions(
            username: username, password: password);

        expect(result, isA<List<Session>>());
        expect(result.first == session, isTrue);
        expect(result.length, 2);
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildErrorResponse(
            Urls.listSessionsOperation,
            'An error occurred',
            'liste');

        HttpClientMock.stubPost(clientMock, Urls.signetsAPI, stubResponse);

        expect(
            service.getSessions(
                username: username, password: password),
            throwsA(isInstanceOf<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });
  });
}

String buildResponse(String operation, String body, String firstElement) =>
    '<?xml version="1.0" encoding="utf-8"?> '
    '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> '
    '<soap:Body> '
    '<${operation}Response xmlns="http://etsmtl.ca/"> '
    '<erreur /> '
    '<$firstElement>'
    '$body'
    '</$firstElement>'
    '</${operation}Response>'
    '</soap:Body>'
    '</soap:Envelope>';

String buildErrorResponse(
        String operation, String error, String firstElement) =>
    '<?xml version="1.0" encoding="utf-8"?> '
    '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> '
    '<soap:Body>'
    '<${operation}Response xmlns="http://etsmtl.ca/"> '
    '<erreur>'
    '$error'
    '</erreur>'
    '<$firstElement /> '
    '</${operation}Response>'
    '</soap:Body>'
    '</soap:Envelope>';
