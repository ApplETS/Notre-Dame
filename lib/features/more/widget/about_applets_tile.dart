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

class AboutAppletsTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_about_applets_title),
      leading: Hero(
        tag: 'about',
        child: Image.asset(
          "assets/images/favicon_applets.png",
          height: 24,
          width: 24,
        ),
      ),
      onTap: () {
        _analyticsService.logEvent("MoreView", "About App|ETS clicked");
        model.navigationService.pushNamed(RouterPaths.about);
      },
    );
  }
}
