// FLUTTER / DART / THIRD-PARTIES

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

//SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/more_viewmodel.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

import 'package:notredame/locator.dart';

class MoreView extends StatelessWidget {
  /// used to redirect on the settings.
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Flutter is Google's UI toolkit for building beautiful, "
                    'natively compiled applications for mobile, web, and desktop '
                    'from a single codebase. Learn more about Flutter at '),
            TextSpan(
                style: textStyle.copyWith(color: Theme.of(context).accentColor),
                text: 'https://flutter.dev'),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];

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
                  onTap: () => _navigationService.pushNamed(RouterPaths.about),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_report_bug),
                  leading: const Icon(Icons.bug_report),
                  onTap: () => BetterFeedback.of(context).show(
                    (
                      String feedbackText,
                      Uint8List feedbackScreenshot,
                    ) async {
                      final PackageInfo packageInfo =
                          await PackageInfo.fromPlatform();
                      final File file = await _localFile;
                      await file.writeAsBytes(image.encodePng(image.copyResize(
                          image.decodeImage(feedbackScreenshot),
                          width: 307)));

                      /// Create a GitHub Client, then send issue
                      const String githubApiToken =
                          String.fromEnvironment('GITHUB_API_TOKEN');
                      final github = GitHub(
                          auth: Authentication.withToken(githubApiToken));

                      /// Upload picture to repo
                      github.repositories.createFile(
                          RepositorySlug.full('ApplETS/Notre-Dame-Bug-report'),
                          CreateFile(
                              path: file.path.replaceFirst(
                                  'storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/',
                                  ''),
                              content: base64Encode(file.readAsBytesSync())
                                  .toString(),
                              message: DateTime.now().toString(),
                              committer: CommitUser('clubapplets-server',
                                  'clubapplets@gmail.com'),
                              branch: 'main'));

                      /// Create issue
                      github.issues.create(
                          RepositorySlug.full("ApplETS/Notre-Dame"),
                          IssueRequest(
                              title: 'Issue from ${packageInfo.appName} ',
                              body: " **Describe the issue** \n"
                                  "```$feedbackText```\n\n"
                                  "**Screenshot** \n"
                                  "![screenshot](https://github.com/ApplETS/Notre-Dame-Bug-report/blob/main/${file.path.replaceFirst('storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/', '')}?raw=true)\n\n"
                                  "**Device Infos** \n"
                                  "- **App name:** ${packageInfo.appName} \n"
                                  "- **Package name:** ${packageInfo.packageName}  \n"
                                  "- **Version:** ${packageInfo.version} \n"
                                  "- **Build number:** ${packageInfo.buildNumber} \n"
                                  "- **Platform operating system:** ${Platform.operatingSystem} \n"
                                  "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n",
                              labels: [
                                'bug',
                                'platform: ${Platform.operatingSystem}'
                              ]));
                      file.deleteSync();
                      showToast(
                        AppIntl.current?.thankYouForTheFeedback,
                        position: ToastPosition.center,
                      );
                      BetterFeedback.of(context).hide();
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).more_contributors),
                  leading: const Icon(Icons.people_outline),
                  onTap: () =>
                      _navigationService.pushNamed(RouterPaths.contributors),
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
                        applicationLegalese: '\u{a9} 2021 App|ETS',
                        children: aboutBoxChildren,
                      ),
                      opaque: false,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(AppIntl.of(context).settings_title),
                  leading: const Icon(Icons.settings),
                  onTap: () =>
                      _navigationService.pushNamed(RouterPaths.settings),
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
                            AppIntl.current.more_prompt_log_out_confirmation),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                model.logout(context);
                              },
                              child: Text(AppIntl.current.yes)),
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

/// Get local storage path
Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  return directory.path.replaceFirst('/', '');
}

/// Create empty picture
Future<File> get _localFile async {
  final path = await _localPath;
  final now = DateTime.now();
  return File('$path/bugPicture-${now.hashCode}.png');
}
