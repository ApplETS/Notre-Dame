// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';

// MODELS
import 'package:notredame/core/models/class_session.dart';

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

    group("getClassSessions - ", () {
      const String classSessionXML = '<Seances>'
          '<dateDebut>2020-09-03T18:00:00</dateDebut> '
          '<dateFin>2020-09-03T20:00:00</dateFin> '
          '<coursGroupe>GEN101-01</coursGroupe> '
          '<nomActivite>TP</nomActivite> '
          '<local>À distance</local> '
          '<descriptionActivite>Travaux pratiques</descriptionActivite> '
          '<libelleCours>Libelle du cours</libelleCours> '
          '</Seances>';

      final ClassSession classSession = ClassSession(
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
            classSessionXML + classSessionXML,
            'ListeDesSeances');

        HttpClientMock.stubPost(clientMock, Urls.signetsAPI, stubResponse);

        final result = await service.getClassSessions(
            username: username, password: password, session: session);

        expect(result, isA<List<ClassSession>>());
        expect(result.first == classSession, isTrue);
        expect(result.length, 2);
      });

      group("invalid parameters - ", () {
        test("session", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A202";

          expect(
              service.getClassSessions(
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
              service.getClassSessions(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup1),
              throwsA(isInstanceOf<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getClassSessions(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup2),
              throwsA(isInstanceOf<FormatException>()),
              reason:
              "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getClassSessions(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup3),
              throwsA(isInstanceOf<FormatException>()),
              reason:
              "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getClassSessions(
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
              service.getClassSessions(
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
            service.getClassSessions(
                username: username, password: password, session: session),
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
