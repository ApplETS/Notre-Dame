// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';

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

  /// Returns right icon color for discovery depending on theme.
  Widget getProperIconAccordingToTheme(IconData icon) {
    return (Theme.of(context).brightness == Brightness.dark &&
            isDiscoveryOverlayActive)
        ? Icon(icon, color: Colors.black)
        : Icon(icon);
  }

  /// License text box
  List<Widget> aboutBoxChildren(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    return <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle, text: AppIntl.of(context)!.flutter_license),
            TextSpan(
                style: textStyle.copyWith(color: Colors.blue),
                text: AppIntl.of(context)!.flutter_website,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Utils.launchURL(
                      AppIntl.of(context)!.flutter_website,
                      AppIntl.of(context)!)),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];
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
                ListTile(
                    title: Text(AppIntl.of(context)!.more_about_applets_title),
                    leading: _buildDiscoveryFeatureDescriptionWidget(
                        context,
                        Hero(
                          tag: 'about',
                          child: Image.asset(
                            "assets/images/favicon_applets.png",
                            height: 24,
                            width: 24,
                          ),
                        ),
                        DiscoveryIds.detailsMoreThankYou,
                        model),
                    onTap: () {
                      _analyticsService.logEvent(tag, "About App|ETS clicked");
                      model.navigationService.pushNamed(RouterPaths.about);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.more_report_bug),
                    leading: _buildDiscoveryFeatureDescriptionWidget(
                        context,
                        getProperIconAccordingToTheme(Icons.bug_report),
                        DiscoveryIds.detailsMoreBugReport,
                        model),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Report a bug clicked");
                      model.navigationService.pushNamed(RouterPaths.feedback);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.in_app_review_title),
                    leading: const Icon(Icons.rate_review),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Rate us clicked");
                      MoreViewModel.launchInAppReview();
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.more_contributors),
                    leading: _buildDiscoveryFeatureDescriptionWidget(
                        context,
                        getProperIconAccordingToTheme(Icons.people_outline),
                        DiscoveryIds.detailsMoreContributors,
                        model),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Contributors clicked");
                      model.navigationService
                          .pushNamed(RouterPaths.contributors);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.more_open_source_licenses),
                    leading: const Icon(Icons.code),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Rate us clicked");
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, _, __) => AboutDialog(
                          applicationIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                width: 75,
                                child: Image.asset(
                                    'assets/images/favicon_applets.png')),
                          ),
                          applicationName:
                              AppIntl.of(context)!.more_open_source_licenses,
                          applicationVersion: model.appVersion,
                          applicationLegalese:
                              '\u{a9} ${DateTime.now().year} App|ETS',
                          children: aboutBoxChildren(context),
                        ),
                        opaque: false,
                      ));
                    }),
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
                    leading: _buildDiscoveryFeatureDescriptionWidget(
                        context,
                        getProperIconAccordingToTheme(Icons.question_answer),
                        DiscoveryIds.detailsMoreFaq,
                        model),
                    onTap: () {
                      _analyticsService.logEvent(tag, "FAQ clicked");
                      model.navigationService.pushNamed(RouterPaths.faq,
                          arguments: Utils.getColorByBrightness(
                              context, Colors.white, AppTheme.primaryDark));
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.settings_title),
                    leading: _buildDiscoveryFeatureDescriptionWidget(
                        context,
                        getProperIconAccordingToTheme(Icons.settings),
                        DiscoveryIds.detailsMoreSettings,
                        model),
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

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context,
      Widget icon,
      String featuredId,
      MoreViewModel model) {
    final discovery = getDiscoveryByFeatureId(
        context, DiscoveryGroupIds.pageMore, featuredId);

    return DescribedFeatureOverlay(
        overflowMode: OverflowMode.wrapBackground,
        contentLocation: ContentLocation.below,
        featureId: discovery.featureId,
        title: Text(discovery.title, textAlign: TextAlign.justify),
        description: discovery.details,
        backgroundColor: AppTheme.appletsDarkPurple,
        tapTarget: icon,
        pulseDuration: const Duration(seconds: 5),
        child: icon,
        onComplete: () {
          setState(() {
            isDiscoveryOverlayActive = false;
          });
          return model.discoveryCompleted();
        },
        onOpen: () async {
          setState(() {
            isDiscoveryOverlayActive = true;
          });
          return true;
        });
  }
}
