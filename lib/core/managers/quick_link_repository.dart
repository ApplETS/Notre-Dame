// Dart imports:
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:font_awesome_flutter/name_icon_mapping.dart';

// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/constants/quick_links.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';
import 'package:notredame/core/services/firebase_storage_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/core/services/remote_config_service.dart';

class QuickLinkRepository {
  final CacheManager _cacheManager = locator<CacheManager>();
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();
  final FirebaseStorageService _storageService =
      locator<FirebaseStorageService>();

  static const String quickLinksCacheKey = "quickLinksCache";

  Future<List<QuickLinkData>> getQuickLinkDataFromCache() async {
    final cacheData = await _cacheManager.get(quickLinksCacheKey);
    final responseCache = jsonDecode(cacheData) as List<dynamic>;

    return responseCache
        .map((e) => QuickLinkData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateQuickLinkDataToCache(List<QuickLink> quickLinkList) async {
    final quickLinkDataList = quickLinkList
        .asMap()
        .entries
        .map((e) => QuickLinkData(id: e.value.id, index: e.key))
        .toList();

    await _cacheManager.update(
        quickLinksCacheKey, jsonEncode(quickLinkDataList));
  }

  Future<List<QuickLink>> getDefaultQuickLinks(AppIntl intl) async {
    final values = await _remoteConfigService.quicklinks_values;

    if (values == null || values as List == null || (values as List).isEmpty) {
      return quickLinks(intl);
    }
    final listValues = values as List<dynamic>;
    final List<QuickLink> listQuicklink = [];

    for (var i = 0; i < listValues.length; i++) {
      Widget imageWidget;
      Map<String, dynamic> map = listValues[i] as Map<String, dynamic>;
      if (map['icon'] != null) {
        final String iconName = map['icon'] as String;
        imageWidget = FaIcon(
          faIconNameMapping['solid $iconName'],
          color: AppTheme.etsLightRed,
          size: 64,
        );
      } else if (map['remotePath'] != null) {
        // from cache
        final String remotePathKey = map['remotePath'] as String;
        String imageUrl;
        try {
          imageUrl = await _cacheManager.get(remotePathKey);
        } on Exception catch (_) {
          if (kDebugMode) {
            print(
                "Image not in cache, fetching from cloud storage: $remotePathKey");
          }

          imageUrl =
              await _storageService.getImageUrl(map['remotePath'] as String);
          _cacheManager.update(remotePathKey, imageUrl);
        }

        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          color: AppTheme.etsLightRed,
        );
      }
      final QuickLink quickLink =
          QuickLink.fromJson(listValues[i] as Map<String, dynamic>);
      quickLink.name =
          intl.localeName == "fr" ? quickLink.nameFr : quickLink.nameEn;
      quickLink.image = imageWidget;
      listQuicklink.add(quickLink);
    }

    return listQuicklink;
  }
}
