// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGER
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/signets_api.dart';

// MODELS
import 'package:notredame/core/models/mon_ets_user.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:notredame/core/utils/api_exception.dart';
import 'package:notredame/core/utils/http_exceptions.dart';

// HELPERS
import '../helpers.dart';

// MOCKS
import '../mock/managers/cache_manager_mock.dart';
import '../mock/services/flutter_secure_storage_mock.dart';
import '../mock/services/mon_ets_api_mock.dart';
import '../mock/services/networking_service_mock.dart';
import '../mock/services/signets_api_mock.dart';

void main() {
  AnalyticsService analyticsService;
  MonETSApi monETSApi;
  FlutterSecureStorage secureStorage;
  CacheManager cacheManager;
  SignetsApi signetsApi;
  NetworkingServiceMock networkingService;

  UserRepository manager;

  group('UserRepository - ', () {
    setUp(() {
      // Setup needed service
      analyticsService = setupAnalyticsServiceMock();
      monETSApi = setupMonETSApiMock();
      secureStorage = setupFlutterSecureStorageMock();
      cacheManager = setupCacheManagerMock();
      signetsApi = setupSignetsApiMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      setupLogger();

      manager = UserRepository();
      SignetsApiMock.stubAuthenticate(signetsApi as SignetsApiMock);
    });

    tearDown(() {
      unregister<AnalyticsService>();
      unregister<MonETSApi>();
      unregister<FlutterSecureStorage>();
      clearInteractions(cacheManager);
      unregister<CacheManager>();
      clearInteractions(signetsApi);
      unregister<SignetsApi>();
      unregister<NetworkingService>();
    });

    group('authentication - ', () {
      test('right credentials', () async {
        final MonETSUser user = MonETSUser(
            domain: "ENS", typeUsagerId: 1, username: "right credentials");

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorage.write(
            key: UserRepository.usernameSecureKey, value: user.username));
        verify(secureStorage.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verify(analyticsService.setUserProperties(
            userId: user.username, domain: user.domain));

        expect(manager.monETSUser, user,
            reason: "Verify the right user is saved");
      });

      test('An exception is throw during the MonETSApi call', () async {
        const String username = "exceptionUser";
        MonETSApiMock.stubException(monETSApi as MonETSApiMock, username);

        expect(await manager.authenticate(username: username, password: ""),
            isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the user id isn't set in the analytics
        verify(analyticsService.logError(UserRepository.tag, any, any, any))
            .called(1);

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

    group('authentication Signets - ', () {
      test('right credentials but bad MonETS API', () async {
        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: "AAXXXXXX");

        MonETSApiMock.stubException(monETSApi as MonETSApiMock, user.username,
            exception: HttpException(
                prefix: "MonETSAPI",
                code: 415,
                message:
                    "{ \"Message\": \"The request contains an entity body but no Content-Type header. The inferred media type 'application/octet-stream' is not supported for this resource.\"}"));
        SignetsApiMock.stubAuthenticate(signetsApi as SignetsApiMock,
            connected: true);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorage.write(
            key: UserRepository.usernameSecureKey, value: user.username));
        verify(secureStorage.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verify(analyticsService.setUserProperties(
            userId: user.username, domain: user.domain));
      });

      test('MonETSAPI failed and SignetsAPI return false', () async {
        const String username = "exceptionUser";

        MonETSApiMock.stubException(monETSApi as MonETSApiMock, username,
            exception: HttpException(
                prefix: "MonETSAPI",
                code: 415,
                message:
                    "{ \"Message\": \"The request contains an entity body but no Content-Type header. The inferred media type 'application/octet-stream' is not supported for this resource.\"}"));
        SignetsApiMock.stubAuthenticate(signetsApi as SignetsApiMock);

        expect(await manager.authenticate(username: username, password: ""),
            isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the user id isn't set in the analytics
        verify(analyticsService.logError(UserRepository.tag, any, any, any))
            .called(1);

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
    group('silentAuthenticate - ', () {
      test('credentials are saved so the authentication should be done',
          () async {
        const String username = "username";
        const String password = "password";

        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: password);

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);

        expect(await manager.silentAuthenticate(), isTrue,
            reason: "Result should be true");

        verifyInOrder([
          secureStorage.read(key: UserRepository.usernameSecureKey),
          secureStorage.read(key: UserRepository.passwordSecureKey),
          monETSApi.authenticate(username: username, password: password),
          analyticsService.setUserProperties(
              userId: username, domain: user.domain)
        ]);

        expect(manager.monETSUser, user,
            reason: "The authentication succeed so the user should be set");
      });

      test('credentials are saved but the authentication fail', () async {
        const String username = "username";
        const String password = "password";

        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: password);

        MonETSApiMock.stubAuthenticateException(
            monETSApi as MonETSApiMock, username);

        expect(await manager.silentAuthenticate(), isFalse,
            reason: "Result should be false");

        verifyInOrder([
          secureStorage.read(key: UserRepository.usernameSecureKey),
          secureStorage.read(key: UserRepository.passwordSecureKey),
          monETSApi.authenticate(username: username, password: password),
          analyticsService.logError(UserRepository.tag, any, any, any)
        ]);

        expect(manager.monETSUser, null,
            reason: "The authentication failed so the user should be null");
      });

      test('credentials are not saved so the authentication should not be done',
          () async {
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: null);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: null);

        expect(await manager.silentAuthenticate(), isFalse,
            reason: "Result should be false");

        verifyInOrder(
            [secureStorage.read(key: UserRepository.usernameSecureKey)]);

        verifyNoMoreInteractions(secureStorage);
        verifyZeroInteractions(monETSApi);
        verifyZeroInteractions(analyticsService);

        expect(manager.monETSUser, null,
            reason:
                "The authentication didn't happened so the user should be null");
      });
    });

    group('logOut - ', () {
      test('the user credentials are deleted', () async {
        expect(await manager.logOut(), isTrue);

        expect(manager.monETSUser, null,
            reason: "The user shouldn't be available after a logout");

        verify(secureStorage.delete(key: UserRepository.usernameSecureKey));
        verify(secureStorage.delete(key: UserRepository.passwordSecureKey));

        verifyNever(
            analyticsService.logError(UserRepository.tag, any, any, any));
      });
    });

    group('getPassword - ', () {
      tearDown(() async {
        await manager.logOut();
      });

      test('the user is authenticated so the password should be returned.',
          () async {
        const String username = "username";
        const String password = "password";

        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: password);

        expect(await manager.silentAuthenticate(), isTrue);

        expect(await manager.getPassword(), password,
            reason: "Result should be 'password'");

        verifyInOrder([
          secureStorage.read(key: UserRepository.usernameSecureKey),
          secureStorage.read(key: UserRepository.passwordSecureKey),
          monETSApi.authenticate(username: username, password: password),
          analyticsService.setUserProperties(
              userId: username, domain: user.domain)
        ]);
      });

      test(
          'the user is not authenticated and silent authentication is available, so the user should authenticate.',
          () async {
        const String username = "username";
        const String password = "password";

        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: password);

        expect(await manager.getPassword(), password,
            reason: "Result should be 'password'");

        verifyInOrder([
          analyticsService.logEvent(UserRepository.tag, any),
          secureStorage.read(key: UserRepository.usernameSecureKey),
          secureStorage.read(key: UserRepository.passwordSecureKey),
          monETSApi.authenticate(username: username, password: password),
          analyticsService.setUserProperties(
              userId: username, domain: user.domain)
        ]);
      });

      test(
          'the user is not authenticated and silent authentication is available but fail, an ApiException should be thrown.',
          () async {
        const String username = "username";
        const String password = "password";

        MonETSApiMock.stubAuthenticateException(
            monETSApi as MonETSApiMock, username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.usernameSecureKey,
            valueToReturn: username);
        FlutterSecureStorageMock.stubRead(
            secureStorage as FlutterSecureStorageMock,
            key: UserRepository.passwordSecureKey,
            valueToReturn: password);

        expect(manager.getPassword(), throwsA(isInstanceOf<ApiException>()),
            reason:
                'The authentication failed so an ApiException should be raised.');

        await untilCalled(
            analyticsService.logError(UserRepository.tag, any, any, any));

        verify(analyticsService.logError(UserRepository.tag, any, any, any))
            .called(1);
      });
    });

    group("getPrograms - ", () {
      final List<Program> programs = [
        Program(
            name: 'Genie',
            code: '9999',
            average: '3',
            accumulatedCredits: '3',
            registeredCredits: '4',
            completedCourses: '6',
            failedCourses: '5',
            equivalentCourses: '7',
            status: 'Actif')
      ];

      const String username = "username";

      final MonETSUser user =
          MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

      setUp(() async {
        // Stub to simulate presence of programs cache
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode(programs));

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetPrograms(
            signetsApi as SignetsApiMock, username, []);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingService);
      });

      test("Programs are loaded from cache", () async {
        expect(manager.programs, isNull);
        final results = await manager.getPrograms(fromCacheOnly: true);

        expect(results, isInstanceOf<List<Program>>());
        expect(results, programs);
        expect(manager.programs, programs,
            reason: 'The programs list should now be loaded.');

        verify(cacheManager.get(UserRepository.programsCacheKey));
        verifyNoMoreInteractions(cacheManager);
      });

      test("Trying to load programs from cache but cache doesn't exist",
          () async {
        // Stub to simulate an exception when trying to get the programs from the cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGetException(
            cacheManager as CacheManagerMock, UserRepository.programsCacheKey);

        expect(manager.programs, isNull);
        final results = await manager.getPrograms();

        expect(results, isInstanceOf<List<Program>>());
        expect(results, []);
        expect(manager.programs, []);

        verify(cacheManager.get(UserRepository.programsCacheKey));
        verify(manager.getPassword());
        verifyNever(cacheManager.update(
            UserRepository.programsCacheKey, jsonEncode(programs)));
      });

      test("SignetsAPI return another program", () async {
        // Stub to simulate presence of program cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApi as SignetsApiMock);
        SignetsApiMock.stubGetPrograms(
            signetsApi as SignetsApiMock, username, programs);

        expect(manager.programs, isNull);
        final results = await manager.getPrograms();

        expect(results, isInstanceOf<List<Program>>());
        expect(results, programs);
        expect(manager.programs, programs,
            reason: 'The programs list should now be loaded.');

        verify(cacheManager.get(UserRepository.programsCacheKey));
        verify(manager.getPassword());
        verify(cacheManager.update(
            UserRepository.programsCacheKey, jsonEncode(programs)));
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of program cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetProgramsException(
            signetsApi as SignetsApiMock, username);

        expect(manager.programs, isNull);
        expect(manager.getPrograms(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingService.hasConnectivity());
        expect(manager.programs, [],
            reason: 'The programs list should be empty');

        await untilCalled(
            analyticsService.logError(UserRepository.tag, any, any, any));

        verify(cacheManager.get(UserRepository.programsCacheKey));
        verify(manager.getPassword());
        verify(analyticsService.logError(UserRepository.tag, any, any, any));

        verifyNever(cacheManager.update(UserRepository.programsCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of program cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode([]));

        // Stub to simulate exception when updating cache
        CacheManagerMock.stubUpdateException(
            cacheManager as CacheManagerMock, UserRepository.programsCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetPrograms(
            signetsApi as SignetsApiMock, username, programs);

        expect(manager.programs, isNull);
        final results = await manager.getPrograms();

        expect(results, isInstanceOf<List<Program>>());
        expect(results, programs);
        expect(manager.programs, programs,
            reason:
                'The programs list should now be loaded even if the caching fails.');
      });

      test("Should force fromCacheOnly mode when user has no connectivity",
          () async {
        //Stub the networkingService to return no connectivity
        reset(networkingService);
        NetworkingServiceMock.stubHasConnectivity(networkingService,
            hasConnectivity: false);

        final programsCache = await manager.getPrograms();
        expect(programsCache, programs);
      });
    });

    group("getInfo - ", () {
      final ProfileStudent info = ProfileStudent(
          balance: '99.99',
          firstName: 'John',
          lastName: 'Doe',
          permanentCode: 'DOEJ00000000');

      const String username = "username";

      final MonETSUser user =
          MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

      setUp(() async {
        // Stub to simulate presence of info cache
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.infoCacheKey, jsonEncode(info));

        MonETSApiMock.stubAuthenticate(monETSApi as MonETSApiMock, user);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetInfo(
            signetsApi as SignetsApiMock, username, null);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingService);
      });

      test("Info are loaded from cache", () async {
        expect(manager.info, isNull);
        final results = await manager.getInfo(fromCacheOnly: true);

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, info);
        expect(manager.info, info, reason: 'The info should now be loaded.');

        verify(cacheManager.get(UserRepository.infoCacheKey));
        verifyNoMoreInteractions(cacheManager as CacheManagerMock);
        verifyNoMoreInteractions(signetsApi as SignetsApiMock);
      });

      test("Trying to load info from cache but cache doesn't exist", () async {
        // Stub to simulate an exception when trying to get the info from the cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGetException(
            cacheManager as CacheManagerMock, UserRepository.infoCacheKey);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isNull);
        expect(manager.info, isNull);

        verify(cacheManager.get(UserRepository.infoCacheKey));
        verify(manager.getPassword());
        verifyNever(
            cacheManager.update(UserRepository.infoCacheKey, jsonEncode(info)));
      });

      test("SignetsAPI return another info", () async {
        // Stub to simulate presence of info cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        final ProfileStudent anotherInfo = ProfileStudent(
            balance: '0.0',
            firstName: 'Johnny',
            lastName: 'Doe',
            permanentCode: 'DOEJ00000000');
        reset(signetsApi as SignetsApiMock);
        SignetsApiMock.stubGetInfo(
            signetsApi as SignetsApiMock, username, anotherInfo);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, anotherInfo);
        expect(manager.info, anotherInfo,
            reason: 'The new info should now be loaded.');

        verify(cacheManager.get(UserRepository.infoCacheKey));
        verify(manager.getPassword());
        verify(cacheManager.update(
            UserRepository.infoCacheKey, jsonEncode(anotherInfo)));
      });

      test("SignetsAPI return a info that already exists", () async {
        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApi as SignetsApiMock);
        SignetsApiMock.stubGetInfo(
            signetsApi as SignetsApiMock, username, info);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, info);
        expect(manager.info, info,
            reason: 'The info should not have any duplicata..');

        verify(cacheManager.get(UserRepository.infoCacheKey));
        verify(manager.getPassword());
        verifyNever(
            cacheManager.update(UserRepository.infoCacheKey, jsonEncode(info)));
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of info cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetInfoException(
            signetsApi as SignetsApiMock, username);

        expect(manager.info, isNull);
        expect(manager.getInfo(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.info, null, reason: 'The info should be empty');

        await untilCalled(
            analyticsService.logError(UserRepository.tag, any, any, any));

        verify(cacheManager.get(UserRepository.infoCacheKey));
        verify(manager.getPassword());
        verify(analyticsService.logError(UserRepository.tag, any, any, any));

        verifyNever(cacheManager.update(UserRepository.infoCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of session cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            UserRepository.infoCacheKey, jsonEncode(info));

        // Stub to simulate exception when updating cache
        CacheManagerMock.stubUpdateException(
            cacheManager as CacheManagerMock, UserRepository.infoCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetInfo(
            signetsApi as SignetsApiMock, username, info);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, info);
        expect(manager.info, info,
            reason: 'The info should now be loaded even if the caching fails.');
      });

      test("Should force fromCacheOnly mode when user has no connectivity",
          () async {
        //Stub the networkingService to return no connectivity
        reset(networkingService);
        NetworkingServiceMock.stubHasConnectivity(networkingService,
            hasConnectivity: false);

        final infoCache = await manager.getInfo();
        expect(infoCache, info);
      });
    });
  });
}
