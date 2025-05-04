import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/locator.dart';

import '../../helpers.dart';
import '../mocks/services/flutter_secure_storage_mock.dart';

// ignore_for_file: invalid_use_of_protected_member test file
void main() {
  late FlutterSecureStorageMock mockSecureStorage;
  late BaseStreamRepository<List<Map<String, dynamic>>> repository;

  setUp(() {
    mockSecureStorage = setupFlutterSecureStorageMock();
    setupLogger();

    repository = BaseStreamRepository<List<Map<String, dynamic>>>('test_cache_key');
  });

  tearDown(() {
    locator.reset();
  });

  group('BaseStreamRepository', () {
    test('should send data to new listener', () async {
      repository.value = [
        {'key': 'value'}
      ];
      var streamEvents = 0;
      repository.stream.listen((data) {
        streamEvents++;
        expect(data, [
          {'key': 'value'}
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

        final result = await repository.getFromCache((json) => json);

        expect(result, false);
        expect(streanEvents, 0);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should load lists from cache if it exists', () async {
        final cachedData = json.encode([
          {'key': 'value'}
        ]);
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: cachedData);
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        final result = await repository.getFromCache((json) => json);

        expect(result, true);
        expect(streamEvents, 1);
        expect(repository.value, [
          {'key': 'value'}
        ]);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should load key value data from cache if it exists', () async {
        final repository = BaseStreamRepository<Map<String, dynamic>>('test_cache_key');
        
        final cachedData = json.encode(
          {'key': 'value'}
        );
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: cachedData);
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        final result = await repository.getFromCache((json) => json);

        expect(result, true);
        expect(streamEvents, 1);
        expect(repository.value,
          {'key': 'value'}
        );
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('should handle unsupported JSON format', () async {
        FlutterSecureStorageMock.stubRead(mockSecureStorage, key: 'test_cache_key', valueToReturn: 'invalid_json');
        var streamEvents = 0;
        var streamErrors = 0;

        repository.stream.listen(
          (data) => streamEvents++,
          onError: (error) => streamErrors++,
        );

        final result = await repository.getFromCache((json) => json);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));

        expect(result, false);
        expect(streamEvents, 0, reason: 'No stream event should be emitted');
        expect(streamErrors, 1, reason: 'An error should be emitted');
      });
    });


    group('getFromApi - ', () {
      test('should fetch data from API and cache it', () async {
        final apiResponse = SignetsApiResponse<List<Map<String, dynamic>>>(
          data: [
            {'key': 'value'}
          ],
        );
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        final result = await repository.getFromApi(() async => apiResponse);

        expect(result, true);
        expect(repository.value, [
          {'key': 'value'}
        ]);

        expect(streamEvents, 1);
        verify(mockSecureStorage.write(
          key: 'test_cache_key',
          value: json.encode(apiResponse.data),
        )).called(1);
      });

      test('should not fetch data if cache is still valid', () async {
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

        final result1 = await repository.getFromApi(apiCall);
        final result2 = await repository.getFromApi(apiCall);

        expect(result1, true);
        expect(result2, false);
        expect(streamEvents, 1);
        verify(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).called(1);
      });

      test('should fetch data if forceUpdate is true', () async {
        var streamEvents = 0;
        repository.stream.listen((data) => streamEvents++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

        final result1 = await repository.getFromApi(apiCall);
        final result2 = await repository.getFromApi(apiCall, forceUpdate: true);

        expect(result1, true);
        expect(result2, true);
        expect(streamEvents, 2);
        verify(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).called(2);
      });

      test('should handle API errors', () async {
        final authService = setupAuthServiceMock();
        var streamEvents = 0;
        var streamErrors = 0;
        repository.stream.listen(
          (data) => streamEvents++,
          onError: (error) => streamErrors++,
        );

        when(authService.getToken()).thenAnswer((_) async => "token");
        when(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).thenAnswer((_) async {});

        apiCall() async => throw DioException(requestOptions: RequestOptions(path: 'test'), response: Response(statusCode: 401, requestOptions: RequestOptions(path: 'test')));

        final result = await repository.getFromApi(apiCall);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));
        expect(result, false);
        expect(streamEvents, 0);
        expect(streamErrors, 1);
        verify(authService.getToken()).called(4);
      });

      test('should handle server-side domain errors', () async {
        var streamEvents = 0;
        var streamErrors = 0;
        repository.stream.listen((data) => streamEvents++, onError: (error) => streamErrors++);

        apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: [], error: 'error');

        final result1 = await repository.getFromApi(apiCall);

        // Adding a small delay to ensure the stream has time to emit
        await Future.delayed(Duration(milliseconds: 10));
        expect(result1, false);
        expect(streamEvents, 0);
        expect(streamErrors, 1);
      });
    });
  });
}