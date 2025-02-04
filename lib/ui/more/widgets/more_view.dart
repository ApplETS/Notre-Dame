// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/theme/app_palette.dart';
import 'package:notredame/theme/app_theme.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/more/view_model/more_viewmodel.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/data/services/launch_url_service.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  static const String tag = "MoreView";

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
                style: textStyle.copyWith(color: context.theme.appColors.link),
                text: AppIntl.of(context)!.flutter_website,
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      _launchUrlService.launchInBrowser(AppIntl.of(context)!.flutter_website)),
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
                    leading: Hero(
                          tag: 'about',
                          child: Image.asset(
                            "assets/images/favicon_applets.png",
                            height: 24,
                            width: 24,
                          ),
                        ),
                    onTap: () {
                      _analyticsService.logEvent(tag, "About App|ETS clicked");
                      model.navigationService.pushNamed(RouterPaths.about);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.in_app_review_title),
                    leading: const Icon(Icons.rate_review_outlined),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Rate us clicked");
                      MoreViewModel.launchInAppReview();
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.more_contributors),
                    leading: const Icon(Icons.people_outline),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Contributors clicked");
                      model.navigationService
                          .pushNamed(RouterPaths.contributors);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.more_open_source_licenses),
                    leading: const Icon(Icons.code_outlined),
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
                      leading: const Icon(Icons.privacy_tip_outlined),
                      onTap: () {
                        _analyticsService.logEvent(
                            tag, "Confidentiality clicked");
                        MoreViewModel.launchPrivacyPolicy();
                      }),
                ListTile(
                    title: Text(AppIntl.of(context)!.need_help),
                    leading: const Icon(Icons.question_answer_outlined),
                    onTap: () {
                      _analyticsService.logEvent(tag, "FAQ clicked");
                      model.navigationService.pushNamed(RouterPaths.faq);
                    }),
                ListTile(
                    title: Text(AppIntl.of(context)!.settings_title),
                    leading: const Icon(Icons.settings_outlined),
                    onTap: () {
                      _analyticsService.logEvent(tag, "Settings clicked");
                      model.navigationService.pushNamed(RouterPaths.settings);
                    }),
                ListTile(
                  title: Text(AppIntl.of(context)!.more_log_out),
                  leading: const Icon(Icons.logout_outlined),
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => AlertDialog(
                        title: Text(
                          AppIntl.of(context)!.more_log_out,
                          style: const TextStyle(color: AppPalette.etsLightRed),
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
}
