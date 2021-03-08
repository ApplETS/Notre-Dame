// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/quick_links.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

class QuickLinksViewModel extends BaseViewModel {
  /// used to get all links for ETS page
  final List<QuickLink> quickLinkList;

  QuickLinksViewModel(AppIntl intl): quickLinkList = quickLinks(intl);
}
