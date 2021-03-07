// FLUTTER / DART / THIRD-PARTIES
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/more_viewmodel.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

class MoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MoreViewModel>.reactive(
        viewModelBuilder: () => MoreViewModel(),
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
                  leading: const Icon(Icons.bug_report),
                  onTap: () => BetterFeedback.of(context).show((
                    String feedbackText,
                    Uint8List feedbackScreenshot,
                  ) {
                    model.sendFeedback(
                        context, feedbackText, feedbackScreenshot);
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
                        applicationIcon: const FlutterLogo(),
                        applicationName:
                            AppIntl.of(context).more_open_source_licenses,
                        applicationVersion: model.appVersion,
                        applicationLegalese:
                            '\u{a9} ${DateTime.now().year} App|ETS',
                        children: model.aboutBoxChildren(
                            Theme.of(context).textTheme.bodyText2),
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
                          AppIntl.current.more_log_out,
                          style: const TextStyle(color: Colors.red),
                        ),
                        content: Text(
                            AppIntl.of(context).more_prompt_log_out_confirmation),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                model.logout(context);
                              },
                              child: Text(AppIntl.of(context).yes)),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppIntl.current.no))
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
