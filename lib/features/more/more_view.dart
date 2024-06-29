// MoreView.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/more/widget/contributors_list_tile.dart';
import 'package:notredame/features/more/widget/help_list_tile.dart';
import 'package:notredame/features/more/widget/in_app_review_list_tile';
import 'package:notredame/features/more/widget/logout_list_tile.dart';
import 'package:notredame/features/more/widget/open_source_licenses_list_tile.dart';
import 'package:notredame/features/more/widget/privacy_policy_list_tile.dart';
import 'package:notredame/features/more/widget/report_bug_list_title.dart';
import 'package:notredame/features/more/widget/settings_list_tile.dart';
import 'package:stacked/stacked.dart';

import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';


class MoreView extends StatefulWidget {
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  bool isDiscoveryOverlayActive = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      MoreViewModel.startDiscovery(context);
    });
  }

  /// Returns right icon color for discovery depending on theme.
  Widget getProperIconAccordingToTheme(IconData icon) {
    return (Theme.of(context).brightness == Brightness.dark &&
            isDiscoveryOverlayActive)
        ? Icon(icon, color: Colors.black)
        : Icon(icon);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoreViewModel>.reactive(
        viewModelBuilder: () => MoreViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return BaseScaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.title_more),
              automaticallyImplyLeading: false,
            ),
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                const AboutListTile(),
                ReportBugListTile(),
                InAppReviewListTile(),
                ContributorsListTile(),
                OpenSourceLicensesListTile(),
                if (model.privacyPolicyToggle) PrivacyPolicyListTile(),
                HelpListTile(),
                SettingsListTile(),
                LogoutListTile(),
              ],
            ),
          );
        });
  }
}
