import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:notredame/data/services/signets_client.dart';

void main() {
  late DioAdapter dioAdapter;
  late SignetsClient signetsClient;

  group('SignetsClient - ', () {
    setUp(() {
      final dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      signetsClient = SignetsClient(dio);
    });

    tearDown(() {
      dioAdapter.close();
    });

    group('getSessionList - ', () {
      test('getSessionList should return an empty list when no sessions are available', () async {
        dioAdapter.onGet(
          '/listeSessions',
          (server) => server.reply(200, {"liste": [], "erreur": ""}),
          headers: { 'Authorization': 'Bearer token'}
        );

        final response = await signetsClient.getSessionList();

        expect(response.data, isNotNull);
        expect(response.data!.isEmpty, true);
      });
    
      test('getSessionList should return a list of sessions', () async {
        dioAdapter.onGet(
          '/listeSessions',
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
              "dateFinAnnulationAvecRemboursementNouveauxEtudiants":
              "2023-10-02",
              "dateDebutAnnulationSansRemboursementNouveauxEtudiants":
              "2023-10-03",
              "dateFinAnnulationSansRemboursementNouveauxEtudiants":
              "2023-11-13",
              "dateLimitePourAnnulerASEQ": "2023-09-30"
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
                "dateLimitePourAnnulerASEQ": "2022-09-30"
              }
            ],
            "erreur": ""
          }),
          headers: { 'Authorization': 'Bearer token'}
        );

        final response = await signetsClient.getSessionList();

        expect(response.data, isNotNull);
        expect(response.data!.length, 2);
        expect(response.data![0].shortName, "A2023");
        expect(response.data![1].shortName, "A2022");
      });
    });

    
  });
}