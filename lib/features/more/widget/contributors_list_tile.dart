// widgets/ContributorsListTile.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';

class ContributorsListTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_contributors),
      leading: const Icon(Icons.people_outline),
      onTap: () {
        _analyticsService.logEvent("MoreView", "Contributors clicked");
        model.navigationService.pushNamed(RouterPaths.contributors);
      },
    );
  }
}
