// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';
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

  /// used to get all links for ETS page
  List<QuickLink> quickLinkList = [];

  List<QuickLink> deletedQuickLinks = [];

  final QuickLinkRepository _quickLinkRepository =
      locator<QuickLinkRepository>();

  QuickLinksViewModel(AppIntl intl) : _appIntl = intl;

  Future<List<QuickLink>> getQuickLinks() async {
    List<QuickLinkData> quickLinkDataList = [];
    try {
      quickLinkDataList =
          await _quickLinkRepository.getQuickLinkDataFromCache();
    } catch (e) {
      // if cache is not initialized, return default list
      return _quickLinkRepository.getDefaultQuickLinks(_appIntl);
    }

    // otherwise, return quickLinks according to the cache
    final defaultQuickLinks =
        _quickLinkRepository.getDefaultQuickLinks(_appIntl);
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
    return _quickLinkRepository
        .getDefaultQuickLinks(_appIntl)
        .where((element) => !currentQuickLinkIds.contains(element.id))
        .toList();
  }

  Future deleteQuickLink(int index) async {
    final deletedQuickLink = quickLinkList.removeAt(index);
    deletedQuickLinks.add(deletedQuickLink);
    await _quickLinkRepository.updateQuickLinkDataToCache(quickLinkList);
    notifyListeners();
  }

  Future restoreQuickLink(int index) async {
    final deletedQuickLink = deletedQuickLinks.removeAt(index);
    quickLinkList.add(deletedQuickLink);
    await _quickLinkRepository.updateQuickLinkDataToCache(quickLinkList);
    notifyListeners();
  }

  Future reorderQuickLinks(int oldIndex, int newIndex) async {
    final QuickLink item = quickLinkList.removeAt(oldIndex);
    quickLinkList.insert(newIndex, item);
    await _quickLinkRepository.updateQuickLinkDataToCache(quickLinkList);
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
