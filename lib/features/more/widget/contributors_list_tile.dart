// widgets/contributors_tile.dart

import 'package:flutter/material.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/utils/locator.dart';

class ContributorsTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "MoreView";
  final bool isDiscoveryOverlayActive;

  ContributorsTile({super.key, required this.isDiscoveryOverlayActive});

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_contributors),
      leading: (Theme.of(context).brightness == Brightness.dark &&
              isDiscoveryOverlayActive)
          ? const Icon(Icons.people_outline, color: Colors.black)
          : const Icon(Icons.people_outline),
      onTap: () {
        _analyticsService.logEvent(tag, "Contributors clicked");
        model.navigationService.pushNamed(RouterPaths.contributors);
      },
    );
  }
}
