// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/locator.dart';
import '../../helpers.dart';
import '../mocks/services/auth_service_mock.dart';
import '../mocks/services/flutter_secure_storage_mock.dart';
import '../mocks/services/networking_service_mock.dart';

// ignore_for_file: invalid_use_of_protected_member test file
void main() {
  late FlutterSecureStorageMock mockSecureStorage;
  late NetworkingServiceMock mockNetworkingService;
  late BaseStreamRepository<List<Map<String, dynamic>>> repository;

  setUp(() {
    mockSecureStorage = setupFlutterSecureStorageMock();
    mockNetworkingService = setupNetworkingServiceMock();
    NetworkingServiceMock.stubHasConnectivity(mockNetworkingService, hasConnectivity: true);
    setupLogger();

    repository = BaseStreamRepository<List<Map<String, dynamic>>>('test_cache_key');
  });

  tearDown(() {
    locator.reset();
  });

  group('BaseStreamRepository', () {
    test('should send data to new listener', () async {
      repository.value = [
        {'key': 'value'},
      ];
      var streamEvents = 0;
      repository.stream.listen((data) {
        streamEvents++;
        expect(data, [
          {'key': 'value'},
        ]);
      });

      // Adding a small delay to ensure the stream has time to emit
      await Future.delayed(Duration(milliseconds: 10));
      expect(streamEvents, 1);
    });

    group('getFromCache - ', () {
      test('should return false if no cache exists', () async {
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: null);
        var streanEvents = 0;
        repository.stream.listen((data) => streanEvents++);

        await repository.getFromCache((json) => json);

        expect(streanEvents, 0);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should load lists from cache if it exists', () async {
        final cachedData = json.encode([
          {'key': 'value'},
        ]);
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: cachedData);
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        await repository.getFromCache((json) => json);

        expect(streamEvents, 1);
        expect(repository.value, [
          {'key': 'value'},
        ]);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should load key value data from cache if it exists', () async {
        final repository = BaseStreamRepository<Map<String, dynamic>>('test_cache_key');

        final cachedData = json.encode({'key': 'value'});
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: cachedData);
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        await repository.getFromCache((json) => json);

        expect(streamEvents, 1);
        expect(repository.value, {'key': 'value'});
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should handle unsupported JSON format', () async {
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: 'invalid_json');
        var streamEvents = 0;
        var streamErrors = 0;

        repository.stream.listen((data) => streamEvents++, onError: (error) => streamErrors++);

        await repository.getFromCache((json) => json);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));

        expect(streamEvents, 0, reason: 'No stream event should be emitted');
        expect(streamErrors, 1, reason: 'An error should be emitted');
      });
    });

    group('getFromApi - ', () {
      test('should fetch data from API and cache it', () async {
        final apiResponse = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'key': 'value'},
          ],
        );
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        await repository.getFromApi(() async => apiResponse);

        expect(repository.value, [
          {'key': 'value'},
        ]);

        expect(streamEvents, 1);
        verify(mockSecureStorage.write(key: 'test_cache_key', value: json.encode(apiResponse.data))).called(1);
      });

      test('should not fetch data if cache is still valid', () async {
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

        await repository.getFromApi(apiCall);
        await repository.getFromApi(apiCall);

        expect(streamEvents, 1);
        verify(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).called(1);
      });

      test('should fetch data if forceUpdate is true', () async {
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

        await repository.getFromApi(apiCall);
        await repository.getFromApi(apiCall, forceUpdate: true);

        expect(streamEvents, 2);
        verify(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).called(2);
      });

      test('should handle API errors', () async {
        final authService = setupAuthServiceMock();
        var streamEvents = 0;
        var streamErrors = 0;
        repository.stream.listen((data) => streamEvents++, onError: (error) => streamErrors++);

        AuthServiceMock.stubGetToken(authService, token: 'token');

        apiCall() async => throw DioException(
          requestOptions: RequestOptions(path: 'test'),
          response: Response(statusCode: 401, requestOptions: RequestOptions(path: 'test')),
        );

        await repository.getFromApi(apiCall);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));
        expect(streamEvents, 0);
        expect(streamErrors, 1);
        verify(authService.getToken()).called(4);
      });

      test('should handle server-side domain errors', () async {
        var streamEvents = 0;
        var streamErrors = 0;
        repository.stream.listen((data) => streamEvents++, onError: (error) => streamErrors++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: [], error: 'error');

        await repository.getFromApi(apiCall);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));
        expect(streamEvents, 0);
        expect(streamErrors, 1);
      });

      test('should not fetch data if no network connectivity', () async {
        NetworkingServiceMock.stubHasConnectivity(mockNetworkingService, hasConnectivity: false);
        var streamEvents = 0;
        var streamErrors = 0;
        repository.stream.listen((data) => streamEvents++, onError: (error) => streamErrors++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

        await repository.getFromApi(apiCall);

        await Future.delayed(Duration(milliseconds: 10));
        expect(streamEvents, 0);
        expect(streamErrors, 1);
        verifyNever(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value")));
      });
    });

    group('fetch - ', () {
      test('should perform parallel fetch on first call', () async {
        final cachedData = json.encode([
          {'cached': 'data'},
        ]);
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: cachedData);

        final apiResponse = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'api': 'data'},
          ],
        );

        var streamEvents = [];
        repository.stream.listen((data) => streamEvents.add(data));

        await repository.fetch(() async => apiResponse, (json) => json);

        await Future.delayed(Duration(milliseconds: 10));

        expect(streamEvents.length, 2);
        expect(streamEvents[0], [
          {'cached': 'data'},
        ]);
        expect(streamEvents[1], [
          {'api': 'data'},
        ]);
      });

      test('should use cache on subsequent calls if valid', () async {
        // First fetch to set cache
        final apiResponse1 = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'cached': 'data'},
          ],
        );
        await repository.fetch(() async => apiResponse1, (json) => json);

        var streamEvents = [];
        repository.stream.listen((data) => streamEvents.add(data));

        // Second fetch should use cache
        await repository.fetch(() async => throw 'should not call', (json) => json);

        await Future.delayed(Duration(milliseconds: 10));

        expect(streamEvents.length, 1);
        expect(streamEvents[0], [
          {'cached': 'data'},
        ]);
      });

      test('should fetch from API on subsequent calls if force update', () async {
        // First fetch
        final apiResponse1 = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'cached': 'data'},
          ],
        );
        await repository.fetch(() async => apiResponse1, (json) => json);

        final apiResponse2 = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'api': 'data'},
          ],
        );

        var streamEvents = [];
        repository.stream.listen((data) => streamEvents.add(data));

        // Second fetch with force update
        await repository.fetch(() async => apiResponse2, (json) => json, forceUpdate: true);

        await Future.delayed(Duration(milliseconds: 10));

        expect(streamEvents.length, 2);
        expect(streamEvents[1], [
          {'api': 'data'},
        ]);
      });
    });
  });
}
