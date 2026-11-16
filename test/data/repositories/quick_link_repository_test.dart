// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/models/quick_link_data.dart';
import 'package:notredame/data/models/quick_links.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import '../../helpers.dart';
import '../mocks/services/cache_service_mock.dart';
import '../mocks/services/remote_config_service_mock.dart';

void main() {
  late CacheServiceMock cacheManagerMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late AppIntl intl;

  late QuickLinkRepository quickLinkRepository;

  group("QuickLinkRepository - ", () {
    setUp(() async {
      // Setup needed services and managers
      cacheManagerMock = setupCacheManagerMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupAnalyticsServiceMock();
      intl = await setupAppIntl();

      quickLinkRepository = QuickLinkRepository();
    });

    tearDown(() {
      clearInteractions(cacheManagerMock);
      unregister<CacheService>();
      unregister<RemoteConfigService>();
      unregister<AnalyticsService>();
    });

    group("getQuickLinkDataFromCache - ", () {
      test("QuickLinkData is loaded from cache.", () async {
        // Stub the cache to return some QuickLinkData
        final quickLinkData = QuickLinkData(id: 1, index: 0);
        CacheServiceMock.stubGet(cacheManagerMock, QuickLinkRepository.quickLinksCacheKey, jsonEncode([quickLinkData]));

        final List<QuickLinkData> results = await quickLinkRepository.getQuickLinkDataFromCache();

        expect(results, isInstanceOf<List<QuickLinkData>>());
        expect(results[0].id, quickLinkData.id);
        expect(results[0].index, quickLinkData.index);

        verify(cacheManagerMock.get(QuickLinkRepository.quickLinksCacheKey)).called(1);
      });

      test("Trying to recover QuickLinkData from cache but an exception is raised.", () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubGetException(cacheManagerMock, QuickLinkRepository.quickLinksCacheKey);

        expect(quickLinkRepository.getQuickLinkDataFromCache(), throwsA(isInstanceOf<Exception>()));
      });
    });

    group("updateQuickLinkDataToCache - ", () {
      test("Updating QuickLinkData to cache.", () async {
        // Prepare some QuickLinkData to be cached
        final quickLink = QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');
        final quickLinkData = QuickLinkData(id: quickLink.id, index: 0);

        await quickLinkRepository.updateQuickLinkDataToCache([quickLink]);

        verify(cacheManagerMock.update(QuickLinkRepository.quickLinksCacheKey, jsonEncode([quickLinkData]))).called(1);
      });

      test("Trying to update QuickLinkData to cache but an exception is raised.", () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubUpdateException(cacheManagerMock, QuickLinkRepository.quickLinksCacheKey);

        final quickLink = QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');

        expect(quickLinkRepository.updateQuickLinkDataToCache([quickLink]), throwsA(isInstanceOf<Exception>()));
      });
    });
      group("getQuickLinks - ", () {
      const remoteJson =
          '[{"id":"1","nameFr":"Sécurité","nameEn":"Security","icon":"shield-halved","link":"security"},'
          '{"id":42,"nameFr":"Nouveau","nameEn":"New","link":"https://etsmtl.ca"}]';

      test("Uses Remote Config when valid and saves it to cache.", () async {
        RemoteConfigServiceMock.stubGetQuickLinksValues(remoteConfigServiceMock, toReturn: remoteJson);

        final results = await quickLinkRepository.getQuickLinks(intl);

        expect(results.map((e) => e.id), [1, 42]);
        expect(results[1].link, "https://etsmtl.ca");
        verify(cacheManagerMock.update(QuickLinkRepository.remoteQuickLinksCacheKey, remoteJson)).called(1);
      });

      test("Uses the cached copy when Remote Config is empty.", () async {
        RemoteConfigServiceMock.stubGetQuickLinksValues(remoteConfigServiceMock);
        CacheServiceMock.stubGet(cacheManagerMock, QuickLinkRepository.remoteQuickLinksCacheKey, remoteJson);

        final results = await quickLinkRepository.getQuickLinks(intl);

        expect(results.map((e) => e.id), [1, 42]);
      });

      test("Uses the cached copy when Remote Config is invalid JSON.", () async {
        RemoteConfigServiceMock.stubGetQuickLinksValues(remoteConfigServiceMock, toReturn: "[{not json");
        CacheServiceMock.stubGet(cacheManagerMock, QuickLinkRepository.remoteQuickLinksCacheKey, remoteJson);

        final results = await quickLinkRepository.getQuickLinks(intl);

        expect(results.map((e) => e.id), [1, 42]);
        verifyNever(cacheManagerMock.update(QuickLinkRepository.remoteQuickLinksCacheKey, any));
      });

      test("Falls back to the bundled links when nothing else is available.", () async {
        RemoteConfigServiceMock.stubGetQuickLinksValues(remoteConfigServiceMock);
        CacheServiceMock.stubGetException(cacheManagerMock, QuickLinkRepository.remoteQuickLinksCacheKey);

        final results = await quickLinkRepository.getQuickLinks(intl);

        expect(results.map((e) => e.id), quickLinks(intl).map((e) => e.id));
      });
    });

    group("applyUserPreferences - ", () {
      QuickLink link(int id) => QuickLink(id: id, image: const Text(""), name: 'link $id', link: 'url');

      test("No saved order: everything visible in remote order.", () {
        final result = QuickLinkRepository.applyUserPreferences(
          available: [link(1), link(2), link(3)],
          savedOrder: null,
          hiddenIds: null,
          legacyKnownIds: {1, 2, 3},
        );

        expect(result.visible.map((e) => e.id), [1, 2, 3]);
        expect(result.hidden, isEmpty);
      });

      test("New remote link is appended without resetting the user's order.", () {
        final result = QuickLinkRepository.applyUserPreferences(
          available: [link(1), link(2), link(3), link(4)],
          savedOrder: [QuickLinkData(id: 3, index: 0), QuickLinkData(id: 1, index: 1)],
          hiddenIds: [2],
          legacyKnownIds: {1, 2, 3},
        );

        expect(result.visible.map((e) => e.id), [3, 1, 4]);
        expect(result.hidden.map((e) => e.id), [2]);
      });

      test("Link removed from Remote Config disappears from both lists.", () {
        final result = QuickLinkRepository.applyUserPreferences(
          available: [link(1), link(3)],
          savedOrder: [QuickLinkData(id: 2, index: 0), QuickLinkData(id: 1, index: 1)],
          hiddenIds: [3, 5],
          legacyKnownIds: {1, 2, 3},
        );

        expect(result.visible.map((e) => e.id), [1]);
        expect(result.hidden.map((e) => e.id), [3]);
      });

      test("Legacy cache (no hidden ids): old links missing from the order stay hidden, new ones are shown.", () {
        final result = QuickLinkRepository.applyUserPreferences(
          available: [link(1), link(2), link(3), link(22)],
          savedOrder: [QuickLinkData(id: 1, index: 0), QuickLinkData(id: 3, index: 1)],
          hiddenIds: null,
          legacyKnownIds: {1, 2, 3},
        );

        expect(result.visible.map((e) => e.id), [1, 3, 22]);
        expect(result.hidden.map((e) => e.id), [2]);
      });
    });

    group("hidden quick links - ", () {
      test("Hidden ids are saved and read from cache.", () async {
        await quickLinkRepository.updateHiddenQuickLinksToCache([
          QuickLink(id: 4, image: const Text(""), name: 'name', link: 'url'),
        ]);
        verify(cacheManagerMock.update(QuickLinkRepository.hiddenQuickLinksCacheKey, jsonEncode([4]))).called(1);

        CacheServiceMock.stubGet(cacheManagerMock, QuickLinkRepository.hiddenQuickLinksCacheKey, jsonEncode([4]));
        expect(await quickLinkRepository.getHiddenQuickLinkIdsFromCache(), [4]);
      });
    });
  });
}
