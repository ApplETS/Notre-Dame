// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/models/quick_link_data.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class QuickLinksViewModel extends FutureViewModel<List<QuickLink>> {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// used to get all links for ETS page
  List<QuickLink> quickLinkList = [];

  List<QuickLink> deletedQuickLinks = [];

  final QuickLinkRepository _quickLinkRepository = locator<QuickLinkRepository>();

  QuickLinksViewModel(AppIntl intl) : _appIntl = intl;

  /// Load the links (Remote Config / cache / bundled) and apply the user's order and hidden links.
  Future<UserQuickLinks> getUserQuickLinks() async {
    final available = await _quickLinkRepository.getQuickLinks(_appIntl);

    List<QuickLinkData>? savedOrder;
    try {
      savedOrder = await _quickLinkRepository.getQuickLinkDataFromCache();
    } catch (_) {
      // user never customized the links
    }

    List<int>? hiddenIds;
    try {
      hiddenIds = await _quickLinkRepository.getHiddenQuickLinkIdsFromCache();
    } catch (_) {
      // saved by an older version of the app, see applyUserPreferences
    }

    return QuickLinkRepository.applyUserPreferences(
      available: available,
      savedOrder: savedOrder,
      hiddenIds: hiddenIds,
      legacyKnownIds: _quickLinkRepository.getDefaultQuickLinks(_appIntl).map((e) => e.id).toSet(),
    );
  }

  Future<void> _saveToCache() async {
    await _quickLinkRepository.updateQuickLinkDataToCache(quickLinkList);
    await _quickLinkRepository.updateHiddenQuickLinksToCache(deletedQuickLinks);
  }

  Future deleteQuickLink(int index) async {
    final deletedQuickLink = quickLinkList.removeAt(index);
    deletedQuickLinks.add(deletedQuickLink);
    await _saveToCache();
    notifyListeners();
  }

  Future restoreQuickLink(int index) async {
    final deletedQuickLink = deletedQuickLinks.removeAt(index);
    quickLinkList.add(deletedQuickLink);
    await _saveToCache();
    notifyListeners();
  }

  Future reorderQuickLinks(int oldIndex, int newIndex) async {
    final QuickLink item = quickLinkList.removeAt(oldIndex);
    quickLinkList.insert(newIndex, item);
    await _saveToCache();
    notifyListeners();
  }

  @override
  Future<List<QuickLink>> futureToRun() async {
    setBusyForObject(quickLinkList, true);
    final userQuickLinks = await getUserQuickLinks();
    quickLinkList = userQuickLinks.visible;
    deletedQuickLinks = userQuickLinks.hidden;
    setBusyForObject(quickLinkList, false);
    return quickLinkList;
  }
}
