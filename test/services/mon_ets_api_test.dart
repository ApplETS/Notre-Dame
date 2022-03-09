// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/services/mon_ets_api.dart';

// MODELS
import 'package:notredame/core/models/mon_ets_user.dart';

// CONSTANTS
import 'package:notredame/core/constants/urls.dart';

// UTILS
import 'package:notredame/core/utils/http_exceptions.dart';

// MOCKS
import '../helpers.dart';
import '../mock/services/http_client_mock.dart';

void main() {
  HttpClientMock clientMock;
  MonETSApi service;

  group('MonETSApi - ', () {
    setUp(() {
      clientMock = HttpClientMock();
      setupLogger();

      service = MonETSApi(clientMock);
    });

    tearDown(() {
      // Clear the mock and all interactions not already processed
      clientMock.close();
      clearInteractions(clientMock);
      reset(clientMock);
    });

    group('authentication - ', () {
      test('right credentials', () async {
        const String username = "username";
        const String password = "password";

        HttpClientMock.stubJsonPost(
            clientMock,
            Urls.authenticationMonETS,
            {"Domaine": "domaine", "TypeUsagerId": 1, "Username": username},
            200);

        final result =
            await service.authenticate(username: username, password: password);

        expect(result, isA<MonETSUser>());
        expect(result.username, username);
      });

      test('wrong credentials / any other errors for now', () async {
        const int statusCode = 500;
        const String message = "An error has occurred.";

        HttpClientMock.stubJsonPost(clientMock, Urls.authenticationMonETS,
            {"Message": message}, statusCode);

        expect(service.authenticate(username: "", password: ""),
            throwsA(isInstanceOf<HttpException>()));
      });
    });
  });
}
