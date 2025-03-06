// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/api_exception.dart';
import '../../helpers.dart';
import '../mocks/services/analytics_service_mock.dart';
import '../mocks/services/cache_service_mock.dart';
import '../mocks/services/flutter_secure_storage_mock.dart';
import '../mocks/services/networking_service_mock.dart';
import '../mocks/services/signets_api_mock.dart';

void main() {
  late AnalyticsServiceMock analyticsServiceMock;
  late FlutterSecureStorageMock secureStorageMock;
  late CacheServiceMock cacheManagerMock;
  late SignetsAPIClientMock signetsApiMock;
  late NetworkingServiceMock networkingServiceMock;

  late UserRepository manager;

  group('UserRepository - ', () {
    setUp(() {
      // Setup needed service
      analyticsServiceMock = setupAnalyticsServiceMock();
      secureStorageMock = setupFlutterSecureStorageMock();
      cacheManagerMock = setupCacheManagerMock();
      signetsApiMock = setupSignetsApiMock();
      networkingServiceMock = setupNetworkingServiceMock();
      setupLogger();

      manager = UserRepository();
    });

    tearDown(() {
      unregister<AnalyticsService>();
      unregister<FlutterSecureStorage>();
      clearInteractions(cacheManagerMock);
      unregister<CacheService>();
      clearInteractions(signetsApiMock);
      unregister<SignetsAPIClient>();
      unregister<NetworkingService>();
    });

    // TODO: end remove when everyone is on the new authentication system
    group('logOut - ', () {
      test('the user credentials are deleted', () async {
        expect(await manager.logOut(), isTrue);

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

        verify(secureStorageMock.delete(key: UserRepository.usernameSecureKey));
        verify(secureStorageMock.deleteAll());
        verify(
            analyticsServiceMock.logError(UserRepository.tag, any, any, any));
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
    // TODO: end remove when everyone is on the new authentication system

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

      setUp(() async {
        // Stub to simulate presence of programs cache
        CacheServiceMock.stubGet(cacheManagerMock,
            UserRepository.programsCacheKey, jsonEncode(programs));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetPrograms(signetsApiMock, []);

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
        CacheServiceMock.stubGetException(
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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetPrograms(
            signetsApiMock, programs);

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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetProgramsException(signetsApiMock);
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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.programsCacheKey, jsonEncode([]));

        // Stub to simulate exception when updating cache
        CacheServiceMock.stubUpdateException(
            cacheManagerMock, UserRepository.programsCacheKey);
        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetPrograms(
            signetsApiMock, programs);

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
          permanentCode: 'DOEJ00000000',
          universalCode: 'AA00000');
      final ProfileStudent defaultInfo = ProfileStudent(
          balance: '', firstName: '', lastName: '', permanentCode: '', universalCode: '');

      setUp(() async {
        // Stub to simulate presence of info cache
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        FlutterSecureStorageMock.stubRead(secureStorageMock,
            key: UserRepository.passwordSecureKey, valueToReturn: '');

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, defaultInfo);

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
        CacheServiceMock.stubGetException(
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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        final ProfileStudent anotherInfo = ProfileStudent(
            balance: '0.0',
            firstName: 'Johnny',
            lastName: 'Doe',
            permanentCode: 'DOEJ00000000',
            universalCode: 'AA00000');
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, anotherInfo);

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
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, info);

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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfoException(signetsApiMock);

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
        CacheServiceMock.stubGet(
            cacheManagerMock, UserRepository.infoCacheKey, jsonEncode(info));

        // Stub to simulate exception when updating cache
        CacheServiceMock.stubUpdateException(
            cacheManagerMock, UserRepository.infoCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetInfo(signetsApiMock, info);

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
  });
}
