// widgets/report_bug_tile.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';

class ReportBugTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "MoreView";
  final bool isDiscoveryOverlayActive;

  ReportBugTile({super.key, required this.isDiscoveryOverlayActive});

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_report_bug),
      leading: (Theme.of(context).brightness == Brightness.dark &&
              isDiscoveryOverlayActive)
          ? const Icon(Icons.bug_report, color: Colors.black)
          : const Icon(Icons.bug_report),
      onTap: () {
        _analyticsService.logEvent(tag, "Report a bug clicked");
        model.navigationService.pushNamed(RouterPaths.feedback);
      },
    );
  }
}
