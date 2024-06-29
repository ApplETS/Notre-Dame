// widgets/in_app_review_tile.dart

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InAppReviewTile extends ViewModelWidget<MoreViewModel> {
  InAppReviewTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.in_app_review_title),
      leading: const Icon(Icons.rate_review),
      onTap: () {
        model.analyticsService.logEvent("MoreView", "Rate us clicked");
        MoreViewModel.launchInAppReview();
      },
    );
  }
}
