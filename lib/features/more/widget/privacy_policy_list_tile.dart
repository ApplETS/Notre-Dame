// widgets/PrivacyPolicyListTile.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';

class PrivacyPolicyListTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.privacy_policy),
      leading: const Icon(Icons.privacy_tip),
      onTap: () {
        _analyticsService.logEvent("MoreView", "Confidentiality clicked");
        MoreViewModel.launchPrivacyPolicy();
      },
    );
  }
}
