// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/constants/quick_links.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:stacked/stacked.dart';

class QuickLinksViewModel extends BaseViewModel {
  /// used to get all links for ETS page
  List<QuickLink> quickLinkList = quickLinks;
}
