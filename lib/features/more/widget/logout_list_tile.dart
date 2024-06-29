// widgets/LogoutListTile.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';

class LogoutListTile extends ViewModelWidget<MoreViewModel> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_log_out),
      leading: const Icon(Icons.logout),
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, _, __) => AlertDialog(
            title: Text(
              AppIntl.of(context)!.more_log_out,
              style: const TextStyle(color: Colors.red),
            ),
            content:
                Text(AppIntl.of(context)!.more_prompt_log_out_confirmation),
            actions: [
              TextButton(
                  onPressed: () async {
                    _analyticsService.logEvent("MoreView", "Log out clicked");
                    model.logout();
                  },
                  child: Text(AppIntl.of(context)!.yes)),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppIntl.of(context)!.no))
            ],
          ),
          opaque: false,
        ),
      ),
    );
  }
}
