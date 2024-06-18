// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:ets_api_clients/exceptions.dart';
import 'package:ets_api_clients/models.dart';
import 'package:ets_api_clients/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/storage/cache_manager.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/services/analytics_service_mock.dart';
import '../mock/services/flutter_secure_storage_mock.dart';
import '../mock/services/networking_service_mock.dart';

void main() {
  late AnalyticsServiceMock analyticsServiceMock;
  late MonETSAPIClientMock monETSApiMock;
  late FlutterSecureStorageMock secureStorageMock;
  late CacheManagerMock cacheManagerMock;
  late SignetsAPIClientMock signetsApiMock;
  late NetworkingServiceMock networkingServiceMock;

  late UserRepository manager;

  group('UserRepository - ', () {
    setUp(() {
      // Setup needed service
      analyticsServiceMock = setupAnalyticsServiceMock();
      monETSApiMock = setupMonETSApiMock();
      secureStorageMock = setupFlutterSecureStorageMock();
      cacheManagerMock = setupCacheManagerMock();
      signetsApiMock = setupSignetsApiMock();
      networkingServiceMock = setupNetworkingServiceMock();
      setupLogger();

      manager = UserRepository();
      SignetsAPIClientMock.stubAuthenticate(signetsApiMock);
    });

    tearDown(() {
      unregister<AnalyticsService>();
      unregister<MonETSAPIClient>();
      unregister<FlutterSecureStorage>();
      clearInteractions(cacheManagerMock);
      unregister<CacheManager>();
      clearInteractions(signetsApiMock);
      unregister<SignetsAPIClient>();
      unregister<NetworkingService>();
    });

    group('authentication - ', () {
      test('right credentials', () async {
        final MonETSUser user = MonETSUser(
            domain: "ENS", typeUsagerId: 1, username: "right credentials");

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorageMock.write(
            key: UserRepository.usernameSecureKey, value: user.username));
        verify(secureStorageMock.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verify(analyticsServiceMock.setUserProperties(
            userId: user.username, domain: user.domain));

        expect(manager.monETSUser, user,
            reason: "Verify the right user is saved");
      });

      test('An exception is throw during the MonETSApi call', () async {
        const String username = "exceptionUser";
        MonETSAPIClientMock.stubException(monETSApiMock, username);

        expect(await manager.authenticate(username: username, password: ""),
            isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the user id isn't set in the analytics
        verify(analyticsServiceMock.logError(UserRepository.tag, any, any, any))
            .called(1);

        // Verify the secureStorage isn't used
        verifyNever(secureStorageMock.write(
            key: UserRepository.usernameSecureKey, value: username));
        verifyNever(secureStorageMock.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verifyNever(analyticsServiceMock.setUserProperties(
            userId: username, domain: anyNamed("domain")));

        expect(manager.monETSUser, null,
            reason: "Verify the user stored should be null");
      });

      test('Verify that localstorage is safely deleted if an exception occurs',
          () async {
        final MonETSUser user = MonETSUser(
            domain: "ENS", typeUsagerId: 1, username: "right credentials");

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);
        FlutterSecureStorageMock.stubWriteException(secureStorageMock,
            key: UserRepository.usernameSecureKey,
            exceptionToThrow: PlatformException(code: "bad key"));

        // Result is false
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isFalse,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorageMock.write(
            key: UserRepository.usernameSecureKey, value: user.username));

        // Verify the user id is set in the analytics
        verify(analyticsServiceMock.setUserProperties(
            userId: user.username, domain: anyNamed("domain")));

        expect(manager.monETSUser, user);
        // Verify the secureStorage is deleted
        verify(secureStorageMock.deleteAll());
      });
    });

    group('authentication Signets - ', () {
      test('right credentials but bad MonETS API', () async {
        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: "AAXXXXXX");

        MonETSAPIClientMock.stubException(monETSApiMock, user.username,
            exception: HttpException(
                prefix: "MonETSAPI",
                code: 415,
                message:
                    "{ \"Message\": \"The request contains an entity body but no Content-Type header. The inferred media type 'application/octet-stream' is not supported for this resource.\"}"));
        SignetsAPIClientMock.stubAuthenticate(signetsApiMock, connected: true);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Verify the secureStorage is used
        verify(secureStorageMock.write(
            key: UserRepository.usernameSecureKey, value: user.username));
        verify(secureStorageMock.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verify(analyticsServiceMock.setUserProperties(
            userId: user.username, domain: user.domain));
      });

      test('MonETSAPI failed and SignetsAPI return false', () async {
        const String username = "exceptionUser";

        MonETSAPIClientMock.stubException(monETSApiMock, username,
            exception: HttpException(
                prefix: "MonETSAPI",
                code: 415,
                message:
                    "{ \"Message\": \"The request contains an entity body but no Content-Type header. The inferred media type 'application/octet-stream' is not supported for this resource.\"}"));
        SignetsAPIClientMock.stubAuthenticate(signetsApiMock);

        expect(await manager.authenticate(username: username, password: ""),
            isFalse,
            reason: "The authentication failed so the result should be false");

        // Verify the user id isn't set in the analytics
        verify(analyticsServiceMock.logError(UserRepository.tag, any, any, any))
            .called(1);

        // Verify the secureStorage isn't used
        verifyNever(secureStorageMock.write(
            key: UserRepository.usernameSecureKey, value: username));
        verifyNever(secureStorageMock.write(
            key: UserRepository.passwordSecureKey, value: ""));

        // Verify the user id is set in the analytics
        verifyNever(analyticsServiceMock.setUserProperties(
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

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);

        expect(await manager.silentAuthenticate(), isTrue,
            reason: "Result should be true");

        verifyInOrder([
          secureStorageMock.read(key: UserRepository.usernameSecureKey),
          secureStorageMock.read(key: UserRepository.passwordSecureKey),
          monETSApiMock.authenticate(username: username, password: password),
          analyticsServiceMock.setUserProperties(
              userId: username, domain: user.domain)
        ]);

        expect(manager.monETSUser, user,
            reason: "The authentication succeed so the user should be set");
      });

      test('credentials are saved but the authentication fail', () async {
        const String username = "username";
        const String password = "password";

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        MonETSAPIClientMock.stubAuthenticateException(monETSApiMock, username);

        expect(await manager.silentAuthenticate(), isFalse,
            reason: "Result should be false");

        verifyInOrder([
          secureStorageMock.read(key: UserRepository.usernameSecureKey),
          secureStorageMock.read(key: UserRepository.passwordSecureKey),
          monETSApiMock.authenticate(username: username, password: password),
          analyticsServiceMock.logError(UserRepository.tag, any, any, any)
        ]);

        expect(manager.monETSUser, null,
            reason: "The authentication failed so the user should be null");
      });

      test('credentials are not saved so the authentication should not be done',
          () async {
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: null);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: null);

        expect(await manager.silentAuthenticate(), isFalse,
            reason: "Result should be false");

        verifyInOrder(
            [secureStorageMock.read(key: UserRepository.usernameSecureKey)]);

        verifyNoMoreInteractions(secureStorageMock);
        verifyZeroInteractions(monETSApiMock);
        verifyZeroInteractions(analyticsServiceMock);

        expect(manager.monETSUser, null,
            reason:
                "The authentication didn't happened so the user should be null");
      });

      test('Verify that localstorage is safely deleted if an exception occurs',
          () async {
        final MonETSUser user = MonETSUser(
            domain: "ENS", typeUsagerId: 1, username: "right credentials");

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);
        FlutterSecureStorageMock.stubReadException(secureStorageMock,
            key: UserRepository.usernameSecureKey,
            exceptionToThrow: PlatformException(code: "bad key"));

        // Result is false
        expect(await manager.silentAuthenticate(), isFalse,
            reason: "Result should be false");

        verifyInOrder([
          secureStorageMock.read(key: UserRepository.usernameSecureKey),
          secureStorageMock.deleteAll(),
          analyticsServiceMock.logError(UserRepository.tag, any, any, any)
        ]);
      });
    });

    group('logOut - ', () {
      test('the user credentials are deleted', () async {
        expect(await manager.logOut(), isTrue);

        expect(manager.monETSUser, null,
            reason: "The user shouldn't be available after a logout");

        verify(secureStorageMock.delete(key: UserRepository.usernameSecureKey));
        verify(secureStorageMock.delete(key: UserRepository.passwordSecureKey));

        verifyNever(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));
      });

      test('Verify that localstorage is safely deleted if an exception occurs',
          () async {
        FlutterSecureStorageMock.stubDeleteException(secureStorageMock,
            key: UserRepository.usernameSecureKey,
            exceptionToThrow: PlatformException(code: "bad key"));

        expect(await manager.logOut(), isFalse);

        expect(manager.monETSUser, null,
            reason: "The user shouldn't be available after a logout");

        verify(secureStorageMock.delete(key: UserRepository.usernameSecureKey));
        verify(secureStorageMock.deleteAll());
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));
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

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        expect(await manager.silentAuthenticate(), isTrue);

        expect(await manager.getPassword(), password,
            reason: "Result should be 'password'");

        verifyInOrder([
          secureStorageMock.read(key: UserRepository.usernameSecureKey),
          secureStorageMock.read(key: UserRepository.passwordSecureKey),
          monETSApiMock.authenticate(username: username, password: password),
          analyticsServiceMock.setUserProperties(
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

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        expect(await manager.getPassword(), password,
            reason: "Result should be 'password'");

        verifyInOrder([
          analyticsServiceMock.logEvent(UserRepository.tag, any),
          secureStorageMock.read(key: UserRepository.usernameSecureKey),
          secureStorageMock.read(key: UserRepository.passwordSecureKey),
          monETSApiMock.authenticate(username: username, password: password),
          analyticsServiceMock.setUserProperties(
              userId: username, domain: user.domain)
        ]);
      });

      test(
          'the user is not authenticated and silent authentication is available but fail, an ApiException should be thrown.',
          () async {
        const String username = "username";
        const String password = "password";

        MonETSAPIClientMock.stubAuthenticateException(monETSApiMock, username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        await manager.silentAuthenticate();

        expect(manager.getPassword(), throwsA(isInstanceOf<ApiException>()),
            reason:
                'The authentication failed so an ApiException should be raised.');

        await untilCalled(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verify(analyticsServiceMock.logError(UserRepository.tag, any, any, any))
            .called(1);
      });

      test('Verify that localstorage is safely deleted if an exception occurs',
          () async {
        const String username = "username";
        const String password = "password";

        final MonETSUser user =
            MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);
        FlutterSecureStorageMock.stubReadException(secureStorageMock,
            key: UserRepository.passwordSecureKey,
            exceptionToThrow: PlatformException(code: "bad key"));

        await manager.authenticate(username: username, password: password);

        expect(manager.getPassword(), throwsA(isInstanceOf<ApiException>()),
            reason: "localStorage failed, should sent out a custom exception");

        await untilCalled(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verify(secureStorageMock.deleteAll());
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));
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
        CacheManagerMock.stubGet(cacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode(programs));

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetPrograms(signetsApiMock, username, []);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Programs are loaded from cache", () async {
        expect(manager.programs, isNull);
        final results = await manager.getPrograms(fromCacheOnly: true);

        expect(results, isInstanceOf<List<Program>>());
        expect(results, programs);
        expect(manager.programs, programs,
            reason: 'The programs list should now be loaded.');

        verify(cacheManagerMock.get(UserRepository.programsCacheKey));
        verifyNoMoreInteractions(cacheManagerMock);
      });

      test("Trying to load programs from cache but cache doesn't exist",
          () async {
        // Stub to simulate an exception when trying to get the programs from the cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGetException(
            cacheManagerMock, UserRepository.programsCacheKey);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        expect(manager.programs, isNull);
        final results = await manager.getPrograms();

        expect(results, isInstanceOf<List<Program>>());
        expect(results, []);
        expect(manager.programs, []);

        verify(cacheManagerMock.get(UserRepository.programsCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verifyNever(cacheManagerMock.update(
            UserRepository.programsCacheKey, jsonEncode(programs)));
      });

      test("SignetsAPI return another program", () async {
        // Stub to simulate presence of program cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetPrograms(
            signetsApiMock, username, programs);

        expect(manager.programs, isNull);
        final results = await manager.getPrograms();

        expect(results, isInstanceOf<List<Program>>());
        expect(results, programs);
        expect(manager.programs, programs,
            reason: 'The programs list should now be loaded.');

        verify(cacheManagerMock.get(UserRepository.programsCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verify(cacheManagerMock.update(
            UserRepository.programsCacheKey, jsonEncode(programs)));
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of program cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetProgramsException(signetsApiMock, username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        expect(manager.programs, isNull);
        expect(manager.getPrograms(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.programs, [],
            reason: 'The programs list should be empty');

        await untilCalled(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verify(cacheManagerMock.get(UserRepository.programsCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verifyNever(
            cacheManagerMock.update(UserRepository.programsCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of program cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));

        // Stub to simulate exception when updating cache
        CacheManagerMock.stubUpdateException(
            cacheManagerMock, UserRepository.programsCacheKey);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetPrograms(
            signetsApiMock, username, programs);

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
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock,
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
      final ProfileStudent defaultInfo = ProfileStudent(
          balance: '', firstName: '', lastName: '', permanentCode: '');

      const String username = "username";

      final MonETSUser user =
          MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

      setUp(() async {
        // Stub to simulate presence of info cache
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        MonETSAPIClientMock.stubAuthenticate(monETSApiMock, user);

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Result is true
        expect(
            await manager.authenticate(username: user.username, password: ""),
            isTrue,
            reason: "Check the authentication is successful");

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, username, defaultInfo);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Info are loaded from cache", () async {
        expect(manager.info, isNull);
        final results = await manager.getInfo(fromCacheOnly: true);

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, info);
        expect(manager.info, info, reason: 'The info should now be loaded.');

        verify(cacheManagerMock.get(UserRepository.infoCacheKey));
        verifyNoMoreInteractions(cacheManagerMock);
        verifyNoMoreInteractions(signetsApiMock);
      });

      test("Trying to load info from cache but cache doesn't exist", () async {
        // Stub to simulate an exception when trying to get the info from the cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGetException(
            cacheManagerMock, UserRepository.infoCacheKey);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, defaultInfo);
        expect(manager.info, defaultInfo);

        verify(cacheManagerMock.get(UserRepository.infoCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verifyNever(cacheManagerMock.update(
            UserRepository.infoCacheKey, jsonEncode(info)));
      });

      test("SignetsAPI return another info", () async {
        // Stub to simulate presence of info cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        final ProfileStudent anotherInfo = ProfileStudent(
            balance: '0.0',
            firstName: 'Johnny',
            lastName: 'Doe',
            permanentCode: 'DOEJ00000000');
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, username, anotherInfo);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, anotherInfo);
        expect(manager.info, anotherInfo,
            reason: 'The new info should now be loaded.');

        verify(cacheManagerMock.get(UserRepository.infoCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verify(cacheManagerMock.update(
            UserRepository.infoCacheKey, jsonEncode(anotherInfo)));
      });

      test("SignetsAPI return a info that already exists", () async {
        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, username, info);

        expect(manager.info, isNull);
        final results = await manager.getInfo();

        expect(results, isInstanceOf<ProfileStudent>());
        expect(results, info);
        expect(manager.info, info,
            reason: 'The info should not have any duplicata..');

        verify(cacheManagerMock.get(UserRepository.infoCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verifyNever(cacheManagerMock.update(
            UserRepository.infoCacheKey, jsonEncode(info)));
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of info cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfoException(signetsApiMock, username);

        expect(manager.info, isNull);
        expect(manager.getInfo(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.info, null, reason: 'The info should be empty');

        await untilCalled(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verify(cacheManagerMock.get(UserRepository.infoCacheKey));
        verify(secureStorageMock.read(key: UserRepository.passwordSecureKey));
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));

        verifyNever(cacheManagerMock.update(UserRepository.infoCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheManagerMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub to simulate exception when updating cache
        CacheManagerMock.stubUpdateException(
            cacheManagerMock, UserRepository.infoCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, username, info);

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
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock,
            hasConnectivity: false);

        final infoCache = await manager.getInfo();
        expect(infoCache, info);
      });
    });

    group("wasPreviouslyLoggedIn - ", () {
      test("check if username and password are present in the secure storage",
          () async {
        const String username = "username";
        const String password = "password";

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        expect(await manager.wasPreviouslyLoggedIn(), isTrue);
      });

      test("check when password is empty in secure storage", () async {
        const String username = "username";
        const String password = "";

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: password);

        expect(await manager.wasPreviouslyLoggedIn(), isFalse);
      });

      test('Verify that localstorage is safely deleted if an exception occurs',
          () async {
        const String username = "username";

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.usernameSecureKey, valueToReturn: username);
        FlutterSecureStorageMock.stubReadException(secureStorageMock,
            key: UserRepository.passwordSecureKey,
            exceptionToThrow: PlatformException(code: "bad key"));

        expect(await manager.wasPreviouslyLoggedIn(), isFalse);
        verify(secureStorageMock.deleteAll());
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));
      });
    });
  });
}
