import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/locator.dart';

import '../../helpers.dart';

// ignore_for_file: invalid_use_of_protected_member test file
void main() {
  late FlutterSecureStorage mockSecureStorage;
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
    group('getFromCache - ', () {
      test('getFromCache should return false if no cache exists', () async {
        when(mockSecureStorage.read(key: 'test_cache_key')).thenAnswer((_) async => null);

        final result = await repository.getFromCache((json) => json);

        expect(result, false);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('getFromCache should load lists from cache if it exists', () async {
        final cachedData = json.encode([
          {'key': 'value'}
        ]);
        when(mockSecureStorage.read(key: 'test_cache_key')).thenAnswer((_) async => cachedData);

        final result = await repository.getFromCache((json) => json);

        expect(result, true);
        expect(repository.value, [
          {'key': 'value'}
        ]);
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('getFromCache should load key value data from cache if it exists', () async {
        final repository = BaseStreamRepository<Map<String, dynamic>>('test_cache_key');
        
        final cachedData = json.encode(
          {'key': 'value'}
        );
        when(mockSecureStorage.read(key: 'test_cache_key')).thenAnswer((_) async => cachedData);

        final result = await repository.getFromCache((json) => json);

        expect(result, true);
        expect(repository.value,
          {'key': 'value'}
        );
        verify(mockSecureStorage.read(key: 'test_cache_key')).called(1);
      });

      test('getFromCache should handle unsupported JSON format', () async {
        when(mockSecureStorage.read(key: 'test_cache_key')).thenAnswer((_) async => 'invalid_json');

        final result = await repository.getFromCache((json) => json);

        expect(result, false);
      });
    });
    

    test('getFromApi should fetch data from API and cache it', () async {
      final apiResponse = SignetsApiResponse<List<Map<String, dynamic>>>(
        data: [
          {'key': 'value'}
        ],
      );

      final result = await repository.getFromApi(() async => apiResponse);

      expect(result, true);
      expect(repository.value, [
        {'key': 'value'}
      ]);

      verify(mockSecureStorage.write(
        key: 'test_cache_key',
        value: json.encode(apiResponse.data),
      )).called(1);
    });

    test('getFromApi should not fetch data if cache is still valid', () async {
      repository.value = [
        {'key': 'value'}
      ];

      apiCall() async => SignetsApiResponse<List<Map<String, dynamic>>>(data: []);

      final result1 = await repository.getFromApi(apiCall);
      final result2 = await repository.getFromApi(apiCall);

      expect(result1, true);
      expect(result2, false);
      verify(mockSecureStorage.write(key: 'test_cache_key', value: anyNamed("value"))).called(1);
    });

    test('getFromApi should handle API errors', () async {
      final authService = setupAuthServiceMock();

      when(authService.getToken()).thenReturn(Future.value("token"));

      final apiResponse = SignetsApiResponse<List<Map<String, dynamic>>>(
        error: 'API error',
      );
      final apiCall = () async => apiResponse;

      expect(
        () async => await repository.getFromApi(apiCall),
        throwsA(isA<String>()),
      );
    });
  });
}