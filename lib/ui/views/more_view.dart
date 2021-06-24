// FLUTTER / DART / THIRD-PARTIES
import 'dart:typed_data';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/more_viewmodel.dart';

// OTHERS
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/core/utils/utils.dart';

class MoreView extends StatefulWidget {
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  @override
  void initState() {
    super.initState();

    /*SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      MoreViewModel(intl: AppIntl.of(context)).startDiscovery(context);
    });*/
  }

  /// License text box
  List<Widget> aboutBoxChildren(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText2;
    return <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle, text: AppIntl.of(context).flutter_license),
            TextSpan(
                style: textStyle.copyWith(color: Colors.blue),
                text: AppIntl.of(context).flutter_website,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Utils.launchURL(
                      AppIntl.of(context).flutter_website,
                      AppIntl.of(context))),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoreViewModel>.reactive(
        viewModelBuilder: () => MoreViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          return BaseScaffold(
            appBar: AppBar(
              title: Text(AppIntl.of(context).title_more),
              automaticallyImplyLeading: false,
            ),
            body: ListView(
              children: [
                ListTile(
                  title: Text(AppIntl.of(context).more_about_applets_title),
                  leading: Hero(
                    tag: 'about',
                    child: Image.asset(
                      "assets/images/favicon_applets.png",
                      height: 24,
                      width: 24,
                    ),
                  ),
                  onTap: () =>
                      model.navigationService.pushNamed(RouterPaths.about),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_report_bug),
                  leading: _buildDiscoveryFeatureDescriptionWidget(
                      context, Icons.bug_report, model),
                  onTap: () => BetterFeedback.of(context).show((
                    String feedbackText,
                    Uint8List feedbackScreenshot,
                  ) {
                    model
                        .sendFeedback(feedbackText, feedbackScreenshot)
                        .then((value) => BetterFeedback.of(context).hide());
                  }),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_contributors),
                  leading: const Icon(Icons.people_outline),
                  onTap: () => model.navigationService
                      .pushNamed(RouterPaths.contributors),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_open_source_licenses),
                  leading: const Icon(Icons.code),
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => AboutDialog(
                        applicationIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: 75,
                              child: Image.asset(
                                  'assets/images/favicon_applets.png')),
                        ),
                        applicationName:
                            AppIntl.of(context).more_open_source_licenses,
                        applicationVersion: model.appVersion,
                        applicationLegalese:
                            '\u{a9} ${DateTime.now().year} App|ETS',
                        children: aboutBoxChildren(context),
                      ),
                      opaque: false,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).settings_title),
                  leading: const Icon(Icons.settings),
                  onTap: () =>
                      model.navigationService.pushNamed(RouterPaths.settings),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_log_out),
                  leading: const Icon(Icons.logout),
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, _, __) => AlertDialog(
                        title: Text(
                          AppIntl.of(context).more_log_out,
                          style: const TextStyle(color: Colors.red),
                        ),
                        content: Text(AppIntl.of(context)
                            .more_prompt_log_out_confirmation),
                        actions: [
                          TextButton(
                              onPressed: () async => model.logout(),
                              child: Text(AppIntl.of(context).yes)),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppIntl.of(context).no))
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
      BuildContext context, IconData icon, MoreViewModel model) {
    final discovery =
        getDiscoveryByFeatureId(context, 'page_more_bug_report_id');

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Icon(icon, color: AppTheme.etsBlack),
      pulseDuration: const Duration(seconds: 5),
      child: Icon(icon),
    );
  }
}
