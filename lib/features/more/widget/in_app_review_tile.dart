// widgets/in_app_review_tile.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/more/more_viewmodel.dart';

class InAppReviewTile extends ViewModelWidget<MoreViewModel> {
  const InAppReviewTile({super.key});

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
