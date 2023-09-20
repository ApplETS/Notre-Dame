// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/managers/cache_manager.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';

// CONSTANTS
import 'package:notredame/core/constants/quick_links.dart';

// OTHERS
import 'package:notredame/locator.dart';

class QuickLinkRepository {
  final CacheManager _cacheManager = locator<CacheManager>();

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

  List<QuickLink> getDefaultQuickLinks(AppIntl intl) {
    return quickLinks(intl);
  }
}
