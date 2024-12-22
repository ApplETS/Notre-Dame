// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/models/quick_link_data.dart';
import '../../../helpers.dart';
import '../../../data/mocks/services/cache_service_mock.dart';

void main() {
  late CacheServiceMock cacheManagerMock;

  late QuickLinkRepository quickLinkRepository;

  group("QuickLinkRepository - ", () {
    setUp(() {
      // Setup needed services and managers
      cacheManagerMock = setupCacheManagerMock();

      quickLinkRepository = QuickLinkRepository();
    });

    tearDown(() {
      clearInteractions(cacheManagerMock);
      unregister<CacheService>();
    });

    group("getQuickLinkDataFromCache - ", () {
      test("QuickLinkData is loaded from cache.", () async {
        // Stub the cache to return some QuickLinkData
        final quickLinkData = QuickLinkData(id: 1, index: 0);
        CacheServiceMock.stubGet(
            cacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]));

        final List<QuickLinkData> results =
            await quickLinkRepository.getQuickLinkDataFromCache();

        expect(results, isInstanceOf<List<QuickLinkData>>());
        expect(results[0].id, quickLinkData.id);
        expect(results[0].index, quickLinkData.index);

        verify(cacheManagerMock.get(QuickLinkRepository.quickLinksCacheKey))
            .called(1);
      });

      test(
          "Trying to recover QuickLinkData from cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubGetException(
            cacheManagerMock, QuickLinkRepository.quickLinksCacheKey);

        expect(quickLinkRepository.getQuickLinkDataFromCache(),
            throwsA(isInstanceOf<Exception>()));
      });
    });

    group("updateQuickLinkDataToCache - ", () {
      test("Updating QuickLinkData to cache.", () async {
        // Prepare some QuickLinkData to be cached
        final quickLink =
            QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');
        final quickLinkData = QuickLinkData(id: quickLink.id, index: 0);

        await quickLinkRepository.updateQuickLinkDataToCache([quickLink]);

        verify(cacheManagerMock.update(QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]))).called(1);
      });

      test(
          "Trying to update QuickLinkData to cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubUpdateException(
            cacheManagerMock, QuickLinkRepository.quickLinksCacheKey);

        final quickLink =
            QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');

        expect(quickLinkRepository.updateQuickLinkDataToCache([quickLink]),
            throwsA(isInstanceOf<Exception>()));
      });
    });
  });
}
