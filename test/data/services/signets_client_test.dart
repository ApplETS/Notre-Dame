// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/course.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/course_evaluation.dart';
import 'package:notredame/domain/models/signets-api/course_review.dart';
import 'package:notredame/domain/models/signets-api/course_summary.dart';
import 'package:notredame/domain/models/signets-api/profile_student.dart';
import 'package:notredame/domain/models/signets-api/program.dart';
import 'package:notredame/domain/models/signets-api/replaced_day.dart';
import 'package:notredame/domain/models/signets-api/schedule_activity.dart';
import 'package:notredame/domain/models/signets-api/teacher.dart';
import 'package:notredame/utils/api_exception.dart';

void main() {
  late DioAdapter dioAdapter;
  late SignetsClient signetsClient;
  late Dio dio;

  group('SignetsClient - ', () {
    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = dioAdapter;
      signetsClient = SignetsClient(dio);
    });

    tearDown(() {
      dioAdapter.close();
    });

    group('getSessionList - ', () {
      test('getSessionList should return an empty list when no sessions are available', () async {
        dioAdapter.onGet(RegExp(r'.*listeSessions'), (server) => server.reply(200, {"liste": [], "erreur": ""}));

        final response = await signetsClient.getSessionList();

        expect(response.data, isNotNull);
        expect(response.data!.isEmpty, true);
      });

      test('getSessionList should return a list of sessions', () async {
        dioAdapter.onGet(
          RegExp(r'.*listeSessions'),
          (server) => server.reply(200, {
            "liste": [
              {
                "abrege": "A2023",
                "auLong": "Automne 2023",
                "dateDebut": "2023-09-05",
                "dateFin": "2023-12-21",
                "dateFinCours": "2023-12-09",
                "dateDebutChemiNot": "2023-08-18",
                "dateFinChemiNot": "2023-05-29",
                "dateDebutAnnulationAvecRemboursement": "2023-09-05",
                "dateFinAnnulationAvecRemboursement": "2023-09-18",
                "dateFinAnnulationAvecRemboursementNouveauxEtudiants": "2023-10-02",
                "dateDebutAnnulationSansRemboursementNouveauxEtudiants": "2023-10-03",
                "dateFinAnnulationSansRemboursementNouveauxEtudiants": "2023-11-13",
                "dateLimitePourAnnulerASEQ": "2023-09-30",
              },
              {
                "abrege": "A2022",
                "auLong": "Automne 2022",
                "dateDebut": "2022-09-06",
                "dateFin": "2022-12-22",
                "dateFinCours": "2022-12-10",
                "dateDebutChemiNot": "2022-05-30",
                "dateFinChemiNot": "2022-06-14",
                "dateDebutAnnulationAvecRemboursement": "2022-09-06",
                "dateFinAnnulationAvecRemboursement": "2022-09-19",
                "dateFinAnnulationAvecRemboursementNouveauxEtudiants": "2022-10-03",
                "dateDebutAnnulationSansRemboursementNouveauxEtudiants": "2022-10-04",
                "dateFinAnnulationSansRemboursementNouveauxEtudiants": "2022-11-15",
                "dateLimitePourAnnulerASEQ": "2022-09-30",
              },
            ],
            "erreur": "",
          }),
        );

        final response = await signetsClient.getSessionList();

        expect(response.data, isNotNull);
        expect(response.data!.length, 2);
        expect(response.data![0].shortName, "A2023");
        expect(response.data![1].shortName, "A2022");
      });
    });

    group('getStudentInfo - ', () {
      test('should parse the student info', () async {
        dioAdapter.onGet(
          RegExp(r'.*infoEtudiant'),
          (server) => server.reply(200, {
            "nom": "Doe   ",
            "prenom": "John  ",
            "codePerm": "DOEJ00000000",
            "codeUniversel": "AA00000",
            "soldeTotal": "0,00\$",
            "masculin": true,
            "erreur": "",
          }),
        );

        final response = await signetsClient.getStudentInfo();

        expect(
          response.requireData(),
          const ProfileStudent(
            balance: "0,00\$",
            firstName: "John",
            lastName: "Doe",
            permanentCode: "DOEJ00000000",
            universalCode: "AA00000",
          ),
        );
      });

      test('should throw an ApiException when Signets returns an error', () async {
        dioAdapter.onGet(RegExp(r'.*infoEtudiant'), (server) => server.reply(200, {"erreur": "Erreur Signets"}));

        final response = await signetsClient.getStudentInfo();

        expect(response.requireData, throwsA(isA<ApiException>()));
      });
    });

    group('getCourses - ', () {
      test('should parse the courses', () async {
        dioAdapter.onGet(
          RegExp(r'.*listeCours'),
          (server) => server.reply(200, {
            "liste": [
              {
                "sigle": "CHM131",
                "groupe": "06",
                "session": "A2023",
                "cote": "A+",
                "nbCredits": 4,
                "titreCours": "Chimie et matériaux",
                "programmeEtudes": "7086",
              },
              {
                "sigle": "LOG430",
                "groupe": "01",
                "session": "H2024",
                "cote": "",
                "nbCredits": 3,
                "titreCours": "Architecture logicielle",
                "programmeEtudes": "7086",
              },
            ],
            "erreur": "",
          }),
        );

        final courses = (await signetsClient.getCourses()).dataOr([]);

        expect(courses, const [
          Course(
            acronym: "CHM131",
            group: "06",
            session: "A2023",
            grade: "A+",
            numberOfCredits: 4,
            title: "Chimie et matériaux",
            programCode: "7086",
          ),
          Course(
            acronym: "LOG430",
            group: "01",
            session: "H2024",
            numberOfCredits: 3,
            title: "Architecture logicielle",
            programCode: "7086",
          ),
        ]);
      });
    });

    group('getPrograms - ', () {
      test('should parse the programs', () async {
        dioAdapter.onGet(
          RegExp(r'.*listeProgrammes'),
          (server) => server.reply(200, {
            "liste": [
              {
                "code": "0725",
                "libelle": "Microprogramme de 1er cycle en enseignement coopératif I",
                "profil": "",
                "statut": "diplômé",
                "sessionDebut": "H2024",
                "sessionFin": "H2024",
                "moyenne": "",
                "nbEquivalences": "0",
                "nbCrsReussis": "1",
                "nbCrsEchoues": "0",
                "nbCreditsInscrits": "0",
                "nbCreditsCompletes": "9",
                "nbCreditsPotentiels": "9",
                "nbCreditsRecherche": "0",
              },
            ],
            "erreur": "",
          }),
        );

        final programs = (await signetsClient.getPrograms()).dataOr([]);

        expect(programs, const [
          Program(
            name: "Microprogramme de 1er cycle en enseignement coopératif I",
            code: "0725",
            average: "",
            accumulatedCredits: "9",
            registeredCredits: "0",
            completedCourses: "1",
            failedCourses: "0",
            equivalentCourses: "0",
            status: "diplômé",
          ),
        ]);
      });
    });

    group('getCourseReviews - ', () {
      test('should send the session and parse the reviews', () async {
        dioAdapter.onGet(
          '/lireEvaluationCours',
          queryParameters: {"session": "A2023"},
          (server) => server.reply(200, {
            "listeEvaluations": [
              {
                "Sigle": "CHM131",
                "Groupe": "06",
                "Enseignant": "John Doe",
                "DateDebutEvaluation": "2023-11-14T00:00:00",
                "DateFinEvaluation": "2023-11-23T23:59:00",
                "TypeEvaluation": "Cours",
                "EstComplete": true,
              },
            ],
            "erreur": "",
          }),
        );

        final reviews = (await signetsClient.getCourseReviews("A2023")).dataOr([]);

        expect(reviews, [
          CourseReview(
            acronym: "CHM131",
            group: "06",
            teacherName: "John Doe",
            type: "Cours",
            startAt: DateTime(2023, 11, 14),
            endAt: DateTime(2023, 11, 23, 23, 59),
            isCompleted: true,
          ),
        ]);
      });
    });

    group('getCoursesActivities - ', () {
      test('should send the session and parse the activities', () async {
        dioAdapter.onGet(
          '/lireHoraireDesSeances',
          queryParameters: {"session": "A2023"},
          (server) => server.reply(200, {
            "ListeDesSeances": [
              {
                "dateDebut": "2023-09-07T09:00:00",
                "dateFin": "2023-09-07T12:30:00",
                "coursGroupe": "CHM131-06",
                "nomActivite": "Cours",
                "local": "B-1404",
                "descriptionActivite": "Activité de cours",
                "libelleCours": "Chimie et matériaux",
              },
            ],
            "erreur": "",
          }),
        );

        final activities = (await signetsClient.getCoursesActivities("A2023")).dataOr([]);

        expect(activities, [
          CourseActivity(
            courseGroup: "CHM131-06",
            courseName: "Chimie et matériaux",
            activityName: "Cours",
            activityDescription: "Activité de cours",
            activityLocation: const ["B-1404"],
            startDateTime: DateTime(2023, 9, 7, 9),
            endDateTime: DateTime(2023, 9, 7, 12, 30),
          ),
        ]);
      });

      test('should return an empty list when the schedule is not available', () async {
        dioAdapter.onGet(
          RegExp(r'.*lireHoraireDesSeances'),
          (server) => server.reply(200, {"ListeDesSeances": [], "erreur": "Aucune donnée pour cette session"}),
        );

        final activities = (await signetsClient.getCoursesActivities("A2023")).dataOr([]);

        expect(activities, isEmpty);
      });

      test('activities should survive a cache round trip', () async {
        final activity = CourseActivity(
          courseGroup: "CHM131-06",
          courseName: "Chimie et matériaux",
          activityName: "Cours",
          activityDescription: "Activité de cours",
          activityLocation: const ["B-1404", "B-1406"],
          startDateTime: DateTime(2023, 9, 7, 9),
          endDateTime: DateTime(2023, 9, 7, 12, 30),
        );

        final decoded = jsonDecode(jsonEncode(activity)) as Map<String, dynamic>;

        expect(CourseActivity.fromJson(decoded), activity);
      });
    });

    group('getScheduleActivities - ', () {
      test('should parse the activities and the teachers', () async {
        dioAdapter.onGet(
          '/listeHoraireEtProf',
          queryParameters: {"session": "A2023"},
          (server) => server.reply(200, {
            "listeActivites": [
              {
                "sigle": "CHM131",
                "groupe": "06",
                "jour": "4",
                "journee": "Jeudi",
                "codeActivite": "C",
                "nomActivite": "Activité de cours",
                "activitePrincipale": "Oui",
                "heureDebut": "09:00",
                "heureFin": "12:30",
                "local": "B-1404",
                "titreCours": "Chimie et matériaux",
              },
            ],
            "listeEnseignants": [
              {
                "localBureau": "B-2325",
                "telephone": "",
                "enseignantPrincipal": "Non",
                "nom": "Doe",
                "prenom": "John",
                "courriel": "john.doe@etsmtl.ca",
              },
            ],
            "erreur": "",
          }),
        );

        final schedule = (await signetsClient.getScheduleActivities("A2023")).requireData();

        expect(schedule.activities, [
          ScheduleActivity(
            courseAcronym: "CHM131",
            courseTitle: "Chimie et matériaux",
            dayOfTheWeek: 4,
            startTime: DateFormat("HH:mm").parse("09:00"),
            endTime: DateFormat("HH:mm").parse("12:30"),
            activityCode: "C",
          ),
        ]);
        expect(schedule.teachers, const [
          Teacher(lastName: "Doe", firstName: "John", email: "john.doe@etsmtl.ca", office: "B-2325"),
        ]);
      });
    });

    group('getCourseSummary - ', () {
      test('should send the course and parse the summary', () async {
        dioAdapter.onGet(
          '/listeElementsEvaluation',
          queryParameters: {"session": "A2023", "sigle": "CHM131", "groupe": "06"},
          (server) => server.reply(200, {
            "noteACeJour": "94,9",
            "scoreFinalSur100": "94,9",
            "moyenneClasse": "74,8",
            "ecartTypeClasse": "13,8",
            "medianeClasse": "75,3",
            "rangCentileClasse": "95",
            "noteACeJourElementsIndividuels": "94,6",
            "noteSur100PourElementsIndividuels": "83,2",
            "tauxPublication": "100,0",
            "liste": [
              {
                "coursGroupe": "CHM131-06",
                "nom": "Examen 1",
                "equipe": "",
                "dateCible": "2023-10-05",
                "note": "99,0",
                "corrigeSur": "100,0+5",
                "ponderation": "15",
                "moyenne": "72,1",
                "ecartType": "18,5",
                "mediane": "76,5",
                "rangCentile": "98",
                "publie": "Oui",
                "messageDuProf": "",
                "ignoreDuCalcul": "Non",
              },
              {
                "coursGroupe": "CHM131-06",
                "nom": "Examen final",
                "equipe": "",
                "dateCible": "",
                "note": "",
                "corrigeSur": "100",
                "ponderation": "40",
                "moyenne": "",
                "ecartType": "",
                "mediane": "",
                "rangCentile": "",
                "publie": "Non",
                "messageDuProf": "",
                "ignoreDuCalcul": "Oui",
              },
            ],
            "erreur": "",
          }),
        );

        final summary = (await signetsClient.getCourseSummary("A2023", "CHM131", "06")).requireData();

        expect(
          summary,
          CourseSummary(
            currentMark: 94.9,
            currentMarkInPercent: 94.9,
            markOutOf: 100.0,
            passMark: 74.8,
            standardDeviation: 13.8,
            median: 75.3,
            percentileRank: 95,
            evaluations: [
              CourseEvaluation(
                courseGroup: "CHM131-06",
                title: "Examen 1",
                targetDate: DateTime(2023, 10, 5),
                mark: 99.0,
                correctedEvaluationOutOf: "100.0+5",
                weight: 15,
                passMark: 72.1,
                standardDeviation: 18.5,
                median: 76.5,
                percentileRank: 98,
                published: true,
                ignore: false,
              ),
              const CourseEvaluation(
                courseGroup: "CHM131-06",
                title: "Examen final",
                correctedEvaluationOutOf: "100",
                weight: 40,
                published: false,
                ignore: true,
              ),
            ],
          ),
        );
        expect(summary.evaluations.first.correctedEvaluationOutOfFormatted, 100.0);
        expect(summary.evaluations.first.weightedGrade, closeTo(14.85, 0.0001));
      });

      test('summary should survive a cache round trip', () async {
        final summary = CourseSummary(
          currentMarkInPercent: 94.9,
          markOutOf: 100,
          percentileRank: 95,
          evaluations: [
            CourseEvaluation(
              courseGroup: "CHM131-06",
              title: "Examen 1",
              targetDate: DateTime(2023, 10, 5),
              mark: 99.0,
              correctedEvaluationOutOf: "100.0+5",
              weight: 15,
              published: true,
              ignore: false,
            ),
          ],
        );
        final course = Course(
          acronym: "CHM131",
          group: "06",
          session: "A2023",
          numberOfCredits: 4,
          title: "Chimie et matériaux",
          programCode: "7086",
          summary: summary,
        );

        final decoded = jsonDecode(jsonEncode(course)) as Map<String, dynamic>;

        expect(Course.fromJson(decoded), course);
      });

      test('should throw an ApiException when the grades are not available', () async {
        dioAdapter.onGet(
          RegExp(r'.*listeElementsEvaluation'),
          (server) => server.reply(200, {"erreur": "Cours ou bordereau de notes inexistant pour CHM131-06"}),
        );

        final response = await signetsClient.getCourseSummary("A2023", "CHM131", "06");

        expect(response.requireData, throwsA(isA<ApiException>()));
      });
    });

    group('getReplacedDays - ', () {
      test('should send the session and parse the replaced days', () async {
        dioAdapter.onGet(
          '/lireJoursRemplaces',
          queryParameters: {"session": "A2023"},
          (server) => server.reply(200, {
            "listeJours": [
              {"dateOrigine": "2023-10-09", "dateRemplacement": "2023-10-10", "description": "Action de grâces"},
            ],
            "erreur": "",
          }),
        );

        final replacedDays = (await signetsClient.getReplacedDays("A2023")).dataOr([]);

        expect(replacedDays, [
          ReplacedDay(
            originalDate: DateTime(2023, 10, 9),
            replacementDate: DateTime(2023, 10, 10),
            description: "Action de grâces",
          ),
        ]);
      });
    });
  });
}
