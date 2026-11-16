// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/models/quick_link_data.dart';
import 'package:notredame/data/models/quick_link_icons.dart';
import 'package:notredame/data/models/quick_link_remote_data.dart';
import 'package:notredame/data/models/quick_links.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

/// Result of merging the available links with what the user customized.
class UserQuickLinks {
  final List<QuickLink> visible;
  final List<QuickLink> hidden;

  const UserQuickLinks({required this.visible, required this.hidden});
}

class QuickLinkRepository {
  static const String tag = "QuickLinkRepository";

  final CacheService _cacheManager = locator<CacheService>();
  final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Order of the visible links chosen by the user ([QuickLinkData] list).
  static const String quickLinksCacheKey = "quickLinksCache";

  /// Ids of the links the user hid.
  static const String hiddenQuickLinksCacheKey = "hiddenQuickLinksCache";

  /// Last valid `quicklinks_values` received from Remote Config, used when Firebase is unavailable.
  static const String remoteQuickLinksCacheKey = "remoteQuickLinksCache";

  /// Every link that can be displayed, in the order defined in Remote Config.
  ///
  /// Source priority:
  ///   1. Remote Config `quicklinks_values` (saved to cache when valid)
  ///   2. last valid value saved in cache
  ///   3. links bundled in the app ([quickLinks])
  Future<List<QuickLink>> getQuickLinks(AppIntl intl) async {
    final remoteData = await _getRemoteQuickLinkData();
    if (remoteData == null) return getDefaultQuickLinks(intl);

    final isFrench = intl.localeName.startsWith('fr');
    return remoteData
        .map(
          (data) => QuickLink(
            id: data.id,
            name: isFrench ? data.nameFr : data.nameEn,
            image: buildQuickLinkImage(icon: data.icon, svg: data.svg),
            link: data.link,
          ),
        )
        .toList();
  }

  Future<List<QuickLinkRemoteData>?> _getRemoteQuickLinkData() async {
    final remoteValue = _remoteConfigService.quickLinksValues;
    if (remoteValue.isNotEmpty) {
      try {
        final parsed = QuickLinkRemoteData.listFromJsonString(remoteValue);
        if (parsed.isNotEmpty) {
          await _cacheManager.update(remoteQuickLinksCacheKey, remoteValue);
          return parsed;
        }
      } on Exception catch (e) {
        _analyticsService.logError(tag, "Invalid quicklinks_values from Remote Config: $e", e);
      }
    }

    try {
      final cachedValue = await _cacheManager.get(remoteQuickLinksCacheKey);
      final parsed = QuickLinkRemoteData.listFromJsonString(cachedValue);
      if (parsed.isNotEmpty) return parsed;
    } on Exception {
      // Nothing cached yet (first launch offline) or corrupted cache: use the bundled links.
    }
    return null;
  }

  Future<List<QuickLinkData>> getQuickLinkDataFromCache() async {
    final cacheData = await _cacheManager.get(quickLinksCacheKey);
    final responseCache = jsonDecode(cacheData) as List<dynamic>;

    return responseCache.map((e) => QuickLinkData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateQuickLinkDataToCache(List<QuickLink> quickLinkList) async {
    final quickLinkDataList = quickLinkList
        .asMap()
        .entries
        .map((e) => QuickLinkData(id: e.value.id, index: e.key))
        .toList();

    await _cacheManager.update(quickLinksCacheKey, jsonEncode(quickLinkDataList));
  }

  Future<List<int>> getHiddenQuickLinkIdsFromCache() async {
    final cacheData = await _cacheManager.get(hiddenQuickLinksCacheKey);
    return (jsonDecode(cacheData) as List<dynamic>).map((e) => e as int).toList();
  }

  Future<void> updateHiddenQuickLinksToCache(List<QuickLink> hiddenQuickLinks) async {
    await _cacheManager.update(hiddenQuickLinksCacheKey, jsonEncode(hiddenQuickLinks.map((e) => e.id).toList()));
  }

  List<QuickLink> getDefaultQuickLinks(AppIntl intl) {
    return quickLinks(intl);
  }

  /// Apply the user's order and hidden links on top of [available].
  ///
  /// - links in [savedOrder] keep the user's order (links removed from Remote Config are dropped)
  /// - links in [hiddenIds] go to the hidden list
  /// - any other link is NEW: appended at the end of the visible list, so adding a link never resets the order
  ///
  /// [legacyKnownIds]: versions before Remote Config only saved the visible order. When [hiddenIds] was never
  /// saved, every link of that old bundled list missing from [savedOrder] is considered hidden by the user.
  static UserQuickLinks applyUserPreferences({
    required List<QuickLink> available,
    required List<QuickLinkData>? savedOrder,
    required List<int>? hiddenIds,
    required Set<int> legacyKnownIds,
  }) {
    if (savedOrder == null) {
      return UserQuickLinks(visible: List.of(available), hidden: []);
    }

    final byId = {for (final link in available) link.id: link};
    final sortedOrder = List.of(savedOrder)..sort((a, b) => a.index.compareTo(b.index));
    final orderedIds = sortedOrder.map((e) => e.id).toList();
    final orderedIdSet = orderedIds.toSet();
    final hiddenIdSet = (hiddenIds ?? legacyKnownIds.where((id) => !orderedIdSet.contains(id))).toSet();

    final visible = <QuickLink>[
      for (final id in orderedIds)
        if (byId.containsKey(id)) byId[id]!,
      for (final link in available)
        if (!orderedIdSet.contains(link.id) && !hiddenIdSet.contains(link.id)) link,
    ];
    final hidden = <QuickLink>[
      for (final link in available)
        if (!orderedIdSet.contains(link.id) && hiddenIdSet.contains(link.id)) link,
    ];

    return UserQuickLinks(visible: visible, hidden: hidden);
  }
}
