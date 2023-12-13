// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/services/firebase_storage_mock.dart';
import '../mock/services/remote_config_service_mock.dart';

void main() {
  AppIntl appIntl;
  CacheManager cacheManager;
  QuickLinkRepository quickLinkRepository;
  RemoteConfigServiceMock remoteConfigServiceMock;
  FirebaseStorageServiceMock storageServiceMock;

  group("QuickLinkRepository - ", () {
    setUp(() async {
      // Setup needed services and managers
      cacheManager = setupCacheManagerMock();
      setupAnalyticsServiceMock();
      appIntl = await setupAppIntl();
      remoteConfigServiceMock =
          setupRemoteConfigServiceMock() as RemoteConfigServiceMock;
      storageServiceMock =
          setupFirebaseStorageServiceMock() as FirebaseStorageServiceMock;
      quickLinkRepository = QuickLinkRepository();
    });

    tearDown(() {
      clearInteractions(cacheManager);
      unregister<CacheManager>();
      unregister<RemoteConfigService>();
    });

    group("getQuickLinkDataFromCache - ", () {
      test("QuickLinkData is loaded from cache.", () async {
        // Stub the cache to return some QuickLinkData
        final quickLinkData = QuickLinkData(id: 1, index: 0);
        CacheManagerMock.stubGet(
            cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]));

        final List<QuickLinkData> results =
            await quickLinkRepository.getQuickLinkDataFromCache();

        expect(results, isInstanceOf<List<QuickLinkData>>());
        expect(results[0].id, quickLinkData.id);
        expect(results[0].index, quickLinkData.index);

        verify(cacheManager.get(QuickLinkRepository.quickLinksCacheKey))
            .called(1);
      });

      test(
          "Trying to recover QuickLinkData from cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheManagerMock.stubGetException(cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey);

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

        verify(cacheManager.update(QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]))).called(1);
      });

      test(
          "Trying to update QuickLinkData to cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheManagerMock.stubUpdateException(cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey);

        final quickLink =
            QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');

        expect(quickLinkRepository.updateQuickLinkDataToCache([quickLink]),
            throwsA(isInstanceOf<Exception>()));
      });
    });

    group("getDefaultQuickLinks", () {
      final quicklinkRemoteConfigRemoteImageStub = [
        {
          "id": "1",
          "nameEn": "ETS Portal",
          "nameFr": "Portail de l'ÉTS",
          "remotePath": "ic_monets.png"
        },
      ];

      final quicklinkRemoteConfigIconStub = [
        {
          "id": "1",
          "nameEn": "Répertoire",
          "nameFr": "Directory",
          "icon": "address-book"
        },
      ];

      test("Trying to get quicklinks when remote config is inacessible.",
          () async {
        // Arrange
        // Stub the remote config to return null
        RemoteConfigServiceMock.stubGetQuickLinks(remoteConfigServiceMock);

        // Act
        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);

        // Assert
        verify(remoteConfigServiceMock.quicklinksValues).called(1);
        verifyNoMoreInteractions(remoteConfigServiceMock);
        verifyNoMoreInteractions(cacheManager);
        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        // There should have 9 quicklinks if none is found in remote config
        expect(quickLinks.length, 9);
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i + 1);
        }
      });

      test(
          "Trying to get quicklinks from remote config with one icon attribute.",
          () async {
        // Arrange
        // Stub the remote config to have values for quicklinks
        RemoteConfigServiceMock.stubGetQuickLinks(remoteConfigServiceMock,
            toReturn: quicklinkRemoteConfigIconStub);
        // Act
        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);
        // Assert
        verify(remoteConfigServiceMock.quicklinksValues).called(1);
        verifyNoMoreInteractions(remoteConfigServiceMock);
        verifyNoMoreInteractions(cacheManager);
        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        expect(quickLinks.length, 1);
        expect(quickLinks[0].image, isInstanceOf<FaIcon>());
        // Verify that the icon is the right one (Icon data, size and color)
        expect((quickLinks[0].image as FaIcon).icon.codePoint, 62137);
        expect((quickLinks[0].image as FaIcon).size, 64);
        expect((quickLinks[0].image as FaIcon).color,
            const Color.fromARGB(255, 239, 62, 69));
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i + 1);
        }
      });

      test(
          "Trying to get quicklinks from remote config with one remote_path attribute (cached).",
          () async {
        // Arrange
        RemoteConfigServiceMock.stubGetQuickLinks(remoteConfigServiceMock,
            toReturn: quicklinkRemoteConfigRemoteImageStub);
        const String url = "https://url.com";
        CacheManagerMock.stubGet(
            cacheManager as CacheManagerMock, "ic_monets.png", url);

        // Act
        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);

        // Assert
        verify(remoteConfigServiceMock.quicklinksValues).called(1);
        verifyNoMoreInteractions(storageServiceMock);

        verify(cacheManager.get("ic_monets.png")).called(1);

        verifyNoMoreInteractions(remoteConfigServiceMock);
        verifyNoMoreInteractions(cacheManager);

        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        expect(quickLinks.length, 1);
        expect(quickLinks[0].image, isInstanceOf<CachedNetworkImage>());
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i + 1);
        }
      });

      test(
          "Trying to get quicklinks from remote config with one remote_path attribute (not previously cached).",
          () async {
        // Arrange
        RemoteConfigServiceMock.stubGetQuickLinks(remoteConfigServiceMock,
            toReturn: quicklinkRemoteConfigRemoteImageStub);
        const String url = "https://url.com";
        CacheManagerMock.stubGetException(
            cacheManager as CacheManagerMock, "ic_monets.png");
        when(storageServiceMock.getImageUrl("ic_monets.png"))
            .thenAnswer((_) async => url);

        // Act
        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);

        // Assert
        verify(remoteConfigServiceMock.quicklinksValues).called(1);
        verifyNoMoreInteractions(remoteConfigServiceMock);

        verify(cacheManager.get("ic_monets.png")).called(1);

        verify(storageServiceMock.getImageUrl("ic_monets.png")).called(1);
        verify(cacheManager.update("ic_monets.png", url)).called(1);
        verifyNoMoreInteractions(storageServiceMock);
        verifyNoMoreInteractions(cacheManager);

        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        expect(quickLinks.length, 1);
        expect(quickLinks[0].image, isInstanceOf<CachedNetworkImage>());
        expect((quickLinks[0].image as CachedNetworkImage).imageUrl, url);
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i + 1);
        }
      });
    });
  });
}
