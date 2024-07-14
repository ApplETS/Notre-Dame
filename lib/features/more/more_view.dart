// more_view.dart

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/more/widget/about_applets_tile.dart';
import 'package:notredame/features/more/widget/contributors_list_tile.dart';
import 'package:notredame/features/more/widget/in_app_review_tile.dart';
import 'package:notredame/features/more/widget/open_source_licenses_list_tile.dart';
import 'package:notredame/features/more/widget/report_bug_tile.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';

class MoreView extends StatefulWidget {
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "MoreView";
  bool isDiscoveryOverlayActive = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      MoreViewModel.startDiscovery(context);
    });
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
                AboutAppletsTile(),
                ReportBugTile(
                    isDiscoveryOverlayActive: isDiscoveryOverlayActive),
                const InAppReviewTile(),
                ContributorsTile(
                    isDiscoveryOverlayActive: isDiscoveryOverlayActive),
                const OpenSourceLicensesTile(),
                if (model.privacyPolicyToggle)
                  ListTile(
                      title: Text(AppIntl.of(context)!.privacy_policy),
                      leading: const Icon(Icons.privacy_tip),
                      onTap: () {
                        _analyticsService.logEvent(
                            tag, "Confidentiality clicked");
                        MoreViewModel.launchPrivacyPolicy();
                      }),
                ListTile(
                    title: Text(AppIntl.of(context)!.need_help),
                    leading:
                        getProperIconAccordingToTheme(Icons.question_answer),
                    onTap: () {
                      _analyticsService.logEvent(tag, "FAQ clicked");
                      model.navigationService.pushNamed(RouterPaths.faq,
                          arguments: Utils.getColorByBrightness(
                              context, Colors.white, AppTheme.primaryDark));
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.settings_title),
                    leading: getProperIconAccordingToTheme(Icons.settings),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Settings clicked");
                      model.navigationService.pushNamed(RouterPaths.settings);
                    }),
                ListTile(
                  title: Text(AppIntl.of(context)!.more_log_out),
                  leading: const Icon(Icons.logout),
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => AlertDialog(
                        title: Text(
                          AppIntl.of(context)!.more_log_out,
                          style: const TextStyle(color: Colors.red),
                        ),
                        content: Text(AppIntl.of(context)!
                            .more_prompt_log_out_confirmation),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                _analyticsService.logEvent(
                                    tag, "Log out clicked");
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
                ),
              ],
            ),
          );
        });
  }

  Widget getProperIconAccordingToTheme(IconData icon) {
    return (Theme.of(context).brightness == Brightness.dark &&
            isDiscoveryOverlayActive)
        ? Icon(icon, color: Colors.black)
        : Icon(icon);
  }
}
