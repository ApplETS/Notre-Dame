// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/quick_links.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';

// OTHERS
import 'package:notredame/locator.dart';

class QuickLinksViewModel extends FutureViewModel<List<QuickLink>> {
  /// Localization class of the application.
  final AppIntl _appIntl;

  @visibleForTesting
  static const String quickLinksCacheKey = "quickLinksCache";

  /// used to get all links for ETS page
  List<QuickLink> quickLinkList = List.empty();

  List<QuickLink> deletedQuickLinks = List.empty();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  QuickLinksViewModel(AppIntl intl) : _appIntl = intl;

  Future<List<QuickLink>> getQuickLinks() async {
    List<QuickLinkData> quickLinkDataList;
    try {
      final cacheData = await _cacheManager.get(quickLinksCacheKey);
      final responseCache = jsonDecode(cacheData) as List<dynamic>;

      quickLinkDataList = responseCache
          .map((e) => QuickLinkData.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // if cache is not initialized, return default list
      return quickLinks(_appIntl);
    }

    // otherwise, return quickLinks according to the cache
    final defaultQuickLinks = quickLinks(_appIntl);
    quickLinkDataList.sort((a, b) => a.index.compareTo(b.index));
    return quickLinkDataList
        .map((data) => defaultQuickLinks
            .firstWhere((quickLink) => quickLink.id == data.id))
        .toList();
  }

  Future<List<QuickLink>> getDeletedQuickLinks() async {
    // Get ids from current quick links
    final currentQuickLinkIds = quickLinkList.map((e) => e.id).toList();

    // Return those not in current quick links but in default list
    return quickLinks(_appIntl)
        .where((element) => !currentQuickLinkIds.contains(element.id))
        .toList();
  }

  Future deleteQuickLink(int index) async {
    // Map current quick links to quick link data
    final deletedQuickLink = quickLinkList.removeAt(index);
    deletedQuickLinks.add(deletedQuickLink);
    final quickLinkDataList = quickLinkList
        .asMap()
        .entries
        .map((e) => QuickLinkData(id: e.value.id, index: e.key))
        .toList();
    await _cacheManager.update(
        quickLinksCacheKey, jsonEncode(quickLinkDataList));
    notifyListeners();
  }

  // Function that updates the cache with the new order of quick links
  Future reorderQuickLinks(int oldIndex, int newIndex) async {
    final QuickLink item = quickLinkList.removeAt(oldIndex);
    quickLinkList.insert(newIndex, item);
    final quickLinkDataList = quickLinkList
        .asMap()
        .entries
        .map((e) => QuickLinkData(id: e.value.id, index: e.key))
        .toList();
    await _cacheManager.update(
        quickLinksCacheKey, jsonEncode(quickLinkDataList));
    notifyListeners();
  }

  @override
  Future<List<QuickLink>> futureToRun() async {
    setBusyForObject(quickLinkList, true);
    quickLinkList = await getQuickLinks();
    deletedQuickLinks = await getDeletedQuickLinks();
    setBusyForObject(quickLinkList, false);
    return quickLinkList;
  }
}
