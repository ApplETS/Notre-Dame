// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/constants/urls.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/course_evaluation.dart';
import 'package:notredame/features/app/signets-api/models/course_review.dart';
import 'package:notredame/features/app/signets-api/models/course_summary.dart';
import 'package:notredame/features/app/signets-api/models/profile_student.dart';
import 'package:notredame/features/app/signets-api/models/program.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/signets-api/models/signets_errors.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/api_exception.dart';
import '../signets_api/http_client_mock_helper.dart';

void main() {
  late MockClient clientMock;
  late SignetsAPIClient service;

  final session = Session(
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

  group('SignetsApi - ', () {
    setUp(() {
      service =
          buildService(MockClient((_) => Future.value(http.Response('', 500))));
    });

    tearDown(() {
      // Clear the mock and all interactions not already processed
      clientMock.close();
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

      final courseActivity = CourseActivity(
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

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getCoursesActivities(
            username: username,
            password: password,
            session: session,
            startDate: DateTime(2020, 9, 3, 18),
            endDate: DateTime(2020, 9, 3, 20));

        expect(result, isA<List<CourseActivity>>());
        expect(result.first == courseActivity, isTrue);
        expect(result.length, 2);
      });

      /// This occur when register for a internship without any other courses
      /// or when the schedule for the desired session isn't available yet.
      test("no courses activities available for the session", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(
            Urls.listClassScheduleOperation,
            SignetsError.scheduleNotAvailable,
            'ListeDesSeances');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getCoursesActivities(
            username: username, password: password, session: session);

        expect(result, isA<List<CourseActivity>>());
        expect(result.length, 0);

        final String stubResponseF = buildErrorResponse(
            Urls.listClassScheduleOperation,
            SignetsError.scheduleNotAvailable,
            'ListeDesSeances');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponseF);
        service = buildService(clientMock);

        final resultF = await service.getCoursesActivities(
            username: username, password: password, session: session);

        expect(resultF, isA<List<CourseActivity>>());
        expect(resultF.length, 0);
      });

      group("invalid parameters - ", () {
        test("session", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A202";

          expect(
              service.getCoursesActivities(
                  username: username, password: password, session: session),
              throwsA(isA<FormatException>()),
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
              throwsA(isA<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup2),
              throwsA(isA<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup3),
              throwsA(isA<FormatException>()),
              reason:
                  "A courseGroup should validate the regex: /^([A-Z]{3}[0-9]{3}-[0-9]{2})/");
          expect(
              service.getCoursesActivities(
                  username: username,
                  password: password,
                  session: session,
                  courseGroup: courseGroup4),
              throwsA(isA<FormatException>()),
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

      test("An error occurred", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(
            Urls.listClassScheduleOperation,
            'An error occurred',
            'ListeDesSeances');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getCoursesActivities(
                username: username, password: password, session: session),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });

      test("Wrong credentials", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(
            Urls.listClassScheduleOperation,
            SignetsError.credentialsInvalid,
            'ListeDesSeances');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getCoursesActivities(
                username: username, password: password, session: session),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });
    group("getScheduleActivities - ", () {
      const String scheduleActivityXML = """
      <HoraireActivite>
          <sigle>GEN101</sigle>
          <groupe>01</groupe>
          <jour>1</jour>
          <journee>Lundi</journee>
          <codeActivite>M</codeActivite>
          <nomActivite>Laboratoire aux 2 semaines</nomActivite>
          <activitePrincipale>Non</activitePrincipale>
          <heureDebut>08:30</heureDebut>
          <heureFin>12:30</heureFin>
          <local>À distance</local>
          <titreCours>Generic title</titreCours>
      </HoraireActivite>
      """;

      final scheduleActivity = ScheduleActivity(
        courseAcronym: 'GEN101',
        courseGroup: '01',
        dayOfTheWeek: 1,
        day: 'Lundi',
        activityCode: ActivityCode.labEvery2Weeks,
        name: 'Laboratoire aux 2 semaines',
        isPrincipalActivity: false,
        startTime: DateFormat('HH:mm').parse("08:30"),
        endTime: DateFormat('HH:mm').parse("12:30"),
        activityLocation: 'À distance',
        courseTitle: 'Generic title',
      );

      test("right credentials and valid parameters", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildResponse(Urls.listeHoraireEtProf,
            scheduleActivityXML + scheduleActivityXML, 'listeActivites');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getScheduleActivities(
            username: username, password: password, session: session);

        expect(result, isA<List<ScheduleActivity>>());
        expect(result.first == scheduleActivity, isTrue);
        expect(result.length, 2);
      });

      test("Wrong credentials", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(Urls.listeHoraireEtProf,
            SignetsError.credentialsInvalid, 'listeActivites');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getScheduleActivities(
                username: username, password: password, session: session),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });

      test("An error occurred", () async {
        const String username = "username";
        const String password = "password";
        const String session = "A2020";

        final String stubResponse = buildErrorResponse(
            Urls.listeHoraireEtProf, 'An error occurred', 'listeActivites');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getScheduleActivities(
                username: username, password: password, session: session),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });

      group("invalid parameters - ", () {
        test("session", () async {
          const String username = "username";
          const String password = "password";
          const String session = "A202";

          expect(
              service.getScheduleActivities(
                  username: username, password: password, session: session),
              throwsA(isA<FormatException>()),
              reason:
                  "The session should validate the regex: /^([A-E-H][0-9]{4})/");
        });
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

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildResponse(
            Urls.listSessionsOperation, sessionXML + sessionXML, 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result =
            await service.getSessions(username: username, password: password);

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
            Urls.listSessionsOperation, 'An error occurred', 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(service.getSessions(username: username, password: password),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getStudentInfo - ", () {
      const String studentInfoXML = '<nom>Doe</nom>'
          '<prenom>John</prenom>'
          '<codePerm>DOEJ00000000</codePerm>'
          '<soldeTotal>99.99</soldeTotal>'
          '<masculin>1</masculin>';

      final studentInfo = ProfileStudent(
          lastName: 'Doe',
          firstName: 'John',
          permanentCode: 'DOEJ00000000',
          balance: '99.99');

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse =
            buildResponse(Urls.infoStudentOperation, studentInfoXML);

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getStudentInfo(
            username: username, password: password);

        expect(result, isA<ProfileStudent>());
        expect(result == studentInfo, isTrue);
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse =
            buildErrorResponse(Urls.infoStudentOperation, 'An error occurred');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(service.getStudentInfo(username: username, password: password),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getPrograms - ", () {
      const String programXML = '<Programme>'
          '<code>9999</code>'
          '<libelle>Genie</libelle>'
          '<profil>Etudiant</profil>'
          '<statut>Actif</statut>'
          '<sessionDebut>2020-01-04</sessionDebut>'
          '<sessionFin>2020-04-04</sessionFin>'
          '<moyenne>3</moyenne>'
          '<nbEquivalences>7</nbEquivalences>'
          '<nbCrsReussis>6</nbCrsReussis>'
          '<nbCrsEchoues>5</nbCrsEchoues>'
          '<nbCreditsInscrits>4</nbCreditsInscrits>'
          '<nbCreditsCompletes>3</nbCreditsCompletes>'
          '<nbCreditsPotentiels>2</nbCreditsPotentiels>'
          '<nbCreditsRecherche>1</nbCreditsRecherche>'
          '</Programme>';

      final program = Program(
          name: 'Genie',
          code: '9999',
          average: '3',
          accumulatedCredits: '3',
          registeredCredits: '4',
          completedCourses: '6',
          failedCourses: '5',
          equivalentCourses: '7',
          status: 'Actif');

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildResponse(
            Urls.listProgramsOperation, programXML + programXML, 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result =
            await service.getPrograms(username: username, password: password);

        expect(result, isA<List<Program>>());
        expect(result.first == program, isTrue);
        expect(result.length, 2);
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildErrorResponse(
            Urls.listProgramsOperation, 'An error occurred', 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(service.getPrograms(username: username, password: password),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getCourses - ", () {
      const String courseWithGradeXML = '<Cours>'
          '<sigle>GEN101</sigle>'
          '<groupe>02</groupe>'
          '<session>H2020</session>'
          '<programmeEtudes>999</programmeEtudes>'
          '<cote>C+</cote>'
          '<nbCredits>3</nbCredits>'
          '<titreCours>Cours générique</titreCours> '
          '</Cours>';

      final courseWithGrade = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          grade: 'C+',
          numberOfCredits: 3,
          title: 'Cours générique');

      const String courseWithoutGradeXML = '<Cours>'
          '<sigle>GEN101</sigle>'
          '<groupe>02</groupe>'
          '<session>H2020</session>'
          '<programmeEtudes>999</programmeEtudes>'
          '<cote /> '
          '<nbCredits>3</nbCredits>'
          '<titreCours>Cours générique</titreCours> '
          '</Cours>';

      final Course courseWithoutGrade = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique');

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildResponse(Urls.listCourseOperation,
            courseWithGradeXML + courseWithoutGradeXML, 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result =
            await service.getCourses(username: username, password: password);

        expect(result, isA<List<Course>>());
        expect(result[0], courseWithGrade);
        expect(result[1], courseWithoutGrade);
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildErrorResponse(
            Urls.listCourseOperation, 'An error occurred', 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(service.getCourses(username: username, password: password),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getCourseSummary - ", () {
      final Course course = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique');

      final courseSummary = CourseSummary(
          currentMark: 5,
          currentMarkInPercent: 50,
          markOutOf: 10,
          passMark: 6,
          standardDeviation: 2.3,
          median: 4.5,
          percentileRank: 99,
          evaluations: [
            CourseEvaluation(
                courseGroup: 'GEN101-01',
                title: 'Test',
                correctedEvaluationOutOf: "20",
                weight: 10,
                published: false,
                teacherMessage: '',
                ignore: false),
            CourseEvaluation(
                courseGroup: 'GEN101-02',
                title: 'Test',
                mark: 18,
                correctedEvaluationOutOf: "20+10",
                weight: 10,
                passMark: 16,
                standardDeviation: 6.4,
                median: 15.3,
                percentileRank: 99,
                published: true,
                teacherMessage: 'Je suis content',
                ignore: false,
                targetDate: DateTime(2020))
          ]);

      const String courseSummaryXml = '<noteACeJour>50</noteACeJour>'
          '<scoreFinalSur100>5</scoreFinalSur100>'
          '<moyenneClasse>6</moyenneClasse>'
          '<ecartTypeClasse>2,3</ecartTypeClasse>'
          '<medianeClasse>4,5</medianeClasse>'
          '<rangCentileClasse>99,0</rangCentileClasse>'
          '<tauxPublication>10</tauxPublication>'
          '<liste>'
          '<ElementEvaluation>'
          '<coursGroupe>GEN101-01</coursGroupe>'
          '<nom>Test</nom>'
          '<equipe /> '
          '<dateCible /> '
          '<note /> '
          '<corrigeSur>20</corrigeSur>'
          '<ponderation>10</ponderation>'
          '<moyenne /> '
          '<ecartType /> '
          '<mediane /> '
          '<rangCentile /> '
          '<publie>Non</publie>'
          '<messageDuProf /> '
          '<ignoreDuCalcul>Non</ignoreDuCalcul> '
          '</ElementEvaluation>'
          '<ElementEvaluation>'
          '<coursGroupe>GEN101-02</coursGroupe>'
          '<nom>Test</nom>'
          '<equipe>Test</equipe>'
          '<dateCible>2020-01-01</dateCible> '
          '<note>18</note>'
          '<corrigeSur>20+10</corrigeSur>'
          '<ponderation>10</ponderation>'
          '<moyenne>16</moyenne> '
          '<ecartType>6,4</ecartType>'
          '<mediane>15.3</mediane>'
          '<rangCentile>99</rangCentile>'
          '<publie>Oui</publie>'
          '<messageDuProf>Je suis content</messageDuProf> '
          '<ignoreDuCalcul>Non</ignoreDuCalcul> '
          '</ElementEvaluation>'
          '</liste>';

      const String courseSummaryEmptyXml = '<erreur /> '
          '<noteACeJour /> '
          '<scoreFinalSur100 /> '
          '<moyenneClasse /> '
          '<ecartTypeClasse /> '
          '<medianeClasse /> '
          '<rangCentileClasse /> '
          '<noteACeJourElementsIndividuels /> '
          '<noteSur100PourElementsIndividuels /> '
          '<tauxPublication>0,0</tauxPublication> '
          '<liste />';

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse =
            buildResponse(Urls.listEvaluationsOperation, courseSummaryXml);

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getCourseSummary(
            username: username, password: password, course: course);

        expect(result, isA<CourseSummary>());
        expect(result, courseSummary);

        expect(result.evaluations[0].weightedGrade, null);
        expect(result.evaluations[1].weightedGrade, 9.0);
      });

      test("Summary is empty", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse =
            buildResponse(Urls.listEvaluationsOperation, courseSummaryEmptyXml);

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getCourseSummary(
                username: username, password: password, course: course),
            throwsA(isA<ApiException>()),
            reason:
                "If the summary is empty, the service should return an error.");
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildErrorResponse(
            Urls.listEvaluationsOperation, 'An error occurred');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getCourseSummary(
                username: username, password: password, course: course),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });

    group("getCoursesEvaluation - ", () {
      const String courseReviewCompletedXML = '<EvaluationCours> '
          '<Sigle>GEN101</Sigle> '
          '<Groupe>01</Groupe> '
          '<Enseignant>April, Alain</Enseignant> '
          '<DateDebutEvaluation>2021-03-19T00:00:00</DateDebutEvaluation> '
          '<DateFinEvaluation>2021-03-28T23:59:00</DateFinEvaluation> '
          '<TypeEvaluation>Cours</TypeEvaluation> '
          '<EstComplete>true</EstComplete> '
          '</EvaluationCours>';

      const String incompleteCourseReviewForSameCourseXML = '<EvaluationCours> '
          '<Sigle>GEN101</Sigle> '
          '<Groupe>01</Groupe> '
          '<Enseignant>Another, Teacher</Enseignant> '
          '<DateDebutEvaluation>2021-03-19T00:00:00</DateDebutEvaluation> '
          '<DateFinEvaluation>2021-03-28T23:59:00</DateFinEvaluation> '
          '<TypeEvaluation>Cours</TypeEvaluation> '
          '<EstComplete>false</EstComplete> '
          '</EvaluationCours>';

      const String courseReviewNotCompletedXML = '<EvaluationCours> '
          '<Sigle>GEN102</Sigle> '
          '<Groupe>01</Groupe> '
          '<Enseignant>April, Alain</Enseignant> '
          '<DateDebutEvaluation>2021-03-19T00:00:00</DateDebutEvaluation> '
          '<DateFinEvaluation>2021-03-28T23:59:00</DateFinEvaluation> '
          '<TypeEvaluation>Cours</TypeEvaluation> '
          '<EstComplete>false</EstComplete> '
          '</EvaluationCours>';

      final courseReviewCompleted = CourseReview(
          acronym: 'GEN101',
          group: '01',
          teacherName: 'April, Alain',
          startAt: DateTime(2021, 03, 19),
          endAt: DateTime(2021, 03, 28, 23, 59),
          type: 'Cours',
          isCompleted: true);

      final incompleteCourseReviewForSameCourse = CourseReview(
          acronym: 'GEN101',
          group: '01',
          teacherName: 'Another, Teacher',
          startAt: DateTime(2021, 03, 19),
          endAt: DateTime(2021, 03, 28, 23, 59),
          type: 'Cours',
          isCompleted: false);

      final courseReviewNotCompleted = CourseReview(
          acronym: 'GEN102',
          group: '01',
          teacherName: 'April, Alain',
          startAt: DateTime(2021, 03, 19),
          endAt: DateTime(2021, 03, 28, 23, 59),
          type: 'Cours',
          isCompleted: false);

      test("right credentials", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildResponse(
            Urls.readCourseReviewOperation,
            courseReviewCompletedXML +
                incompleteCourseReviewForSameCourseXML +
                courseReviewNotCompletedXML,
            'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        final result = await service.getCourseReviews(
            username: username, password: password, session: session);

        expect(result, isA<List<CourseReview>>());
        expect(
            result,
            containsAll([
              courseReviewCompleted,
              incompleteCourseReviewForSameCourse,
              courseReviewNotCompleted
            ]));
      });

      // Currently SignetsAPI doesn't have a clear way to indicate which error
      // occurred (no error code, no change of http code, just a text)
      // so for now whatever the error we will throw a generic error
      test("wrong credentials / an error occurred", () async {
        const String username = "username";
        const String password = "password";

        final String stubResponse = buildErrorResponse(
            Urls.readCourseReviewOperation, 'An error occurred', 'liste');

        clientMock =
            HttpClientMockHelper.stubPost(Urls.signetsAPI, stubResponse);
        service = buildService(clientMock);

        expect(
            service.getCourseReviews(
                username: username, password: password, session: session),
            throwsA(isA<ApiException>()),
            reason:
                "If the SignetsAPI return an error the service should return the error.");
      });
    });
  });
}

SignetsAPIClient buildService(MockClient client) =>
    SignetsAPIClient(client: client);

String buildResponse(String operation, String body, [String? firstElement]) =>
    '<?xml version="1.0" encoding="utf-8"?> '
    '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> '
    '<soap:Body> '
    '<${operation}Response xmlns="http://etsmtl.ca/"> '
    '<${operation}Result>'
    '<erreur /> '
    '${firstElement != null ? '<$firstElement>' : ''}'
    '$body'
    '${firstElement != null ? '</$firstElement>' : ''}'
    '</${operation}Result>'
    '</${operation}Response>'
    '</soap:Body>'
    '</soap:Envelope>';

String buildErrorResponse(String operation, String error,
        [String? firstElement]) =>
    '<?xml version="1.0" encoding="utf-8"?> '
    '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> '
    '<soap:Body>'
    '<${operation}Response xmlns="http://etsmtl.ca/"> '
    '<${operation}Result>'
    '<erreur>'
    '$error'
    '</erreur>'
    '[<$firstElement />]? '
    '</${operation}Result>'
    '</${operation}Response>'
    '</soap:Body>'
    '</soap:Envelope>';
