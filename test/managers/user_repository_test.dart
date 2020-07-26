// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGER
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/analytics_service.dart';

// MODELS
import 'package:notredame/core/models/mon_ets_user.dart';

// HELPERS
import '../helpers.dart';

// MOCKS
import '../mock/services/mon_ets_api_mock.dart';

void main() {
  AnalyticsService analyticsService;
  MonETSApi monETSApi;
  FlutterSecureStorage secureStorage;

  UserRepository manager;

  group('UserRepository - ', () {
    setUp(() {
      // Setup needed service
      analyticsService = setupAnalyticsServiceMock();
      monETSApi = setupMonETSApiMock();
      secureStorage = setupFlutterSecureStorageMock();

      manager = UserRepository();
    });

    tearDown(() {
      unregister<AnalyticsService>();
      unregister<MonETSApi>();
      unregister<FlutterSecureStorage>();
    });

    group('authentication - ', () {
      test('right credentials', () async {
        final MonETSUser user = MonETSUser(
            domaine: "ENS", typeUsagerId: 1, username: "right credentials");

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);

        // Result is true
        expect(await manager.authenticate(username: user.username, password: ""), isTrue,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorage.write(
            key: UserRepository.usernameSecureKey, value: user.username));
        verify(secureStorage.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verify(analyticsService.setUserProperties(
            userId: user.username, domain: user.domaine));

        expect(manager.monETSUser, user,
            reason: "Verify the right user is saved");
      });

      test('MonETSApi throw a HttpException', () async {
        const String username = "exceptionUser";
        MonETSApiMock.stubAuthenticateException(
            monETSApi as MonETSApiMock, username);

        expect(await manager.authenticate(username: username, password: ""), isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the secureStorage isn't used
        verifyNever(secureStorage.write(
            key: UserRepository.usernameSecureKey, value: username));
        verifyNever(secureStorage.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verifyNever(analyticsService.setUserProperties(
            userId: username, domain: anyNamed("domain")));

        expect(manager.monETSUser, null,
            reason: "Verify the user stored should be null");
      });

      test('An exception is throw during the MonETSApi call', () async {
        const String username = "exceptionUser";
        MonETSApiMock.stubException(
            monETSApi as MonETSApiMock, username);

        expect(await manager.authenticate(username: username, password: ""), isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the user id is set in the analytics
        verify(analyticsService.logError(UserRepository.tag, any)).called(1);

        // Verify the secureStorage isn't used
        verifyNever(secureStorage.write(
            key: UserRepository.usernameSecureKey, value: username));
        verifyNever(secureStorage.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verifyNever(analyticsService.setUserProperties(
            userId: username, domain: anyNamed("domain")));

        expect(manager.monETSUser, null,
            reason: "Verify the user stored should be null");
      });
    });
  });
}
