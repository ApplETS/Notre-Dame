import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/utils/app_theme.dart';

class HelpListTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.need_help),
      leading: const Icon(Icons.question_answer),
      onTap: () {
        _analyticsService.logEvent("MoreView", "FAQ clicked");
        model.navigationService.pushNamed(RouterPaths.faq,
            arguments: Utils.getColorByBrightness(
                context, Colors.white, AppTheme.primaryDark));
      },
    );
  }
}
