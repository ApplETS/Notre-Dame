// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked/stacked.dart';
import 'package:oktoast/oktoast.dart';
import 'package:github/github.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

//SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHERS
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class MoreViewModel extends FutureViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Used to redirect on the dashboard.
  final NavigationService navigationService = locator<NavigationService>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  String _appVersion;

  /// Get the application version
  String get appVersion => _appVersion;

  MoreViewModel({@required AppIntl intl}) : _appIntl = intl;

  @override
  Future futureToRun() async {
    setBusy(true);

    await PackageInfo.fromPlatform()
        .then((value) => _appVersion = value.version)
        .onError((error, stackTrace) => null);

    setBusy(false);
    return true;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    showToast(_appIntl.error);
  }

  /// Used to logout user, delete cache, and return to login
  Future<void> logout() async {
    setBusy(true);
    try {
      await _cacheManager.empty();
    } on Exception catch (e) {
      onError(e);
    }
    UserRepository().logOut();
    setBusy(false);
    // Dismiss alertDialog
    navigationService.pop();
    navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
    showToast(_appIntl.login_msg_logout_success);
  }

  /// Create a Github issue with [feedbackText] and the screenshot associated.
  Future<void> sendFeedback(BuildContext context, String feedbackText,
      Uint8List feedbackScreenshot) async {
    final File file = await _localFile;
    await file.writeAsBytes(image.encodePng(
        image.copyResize(image.decodeImage(feedbackScreenshot), width: 307)));

    /// Create a GitHub Client
    const String githubApiToken = String.fromEnvironment('GITHUB_API_TOKEN');
    final github = GitHub(auth: Authentication.withToken(githubApiToken));

    _uploadFileToGithub(github, file);

    await _createGithubIssue(github, file, feedbackText);

    file.deleteSync();
    showToast(
      _appIntl.thank_you_for_the_feedback,
      position: ToastPosition.center,
    );
    BetterFeedback.of(context).hide();
  }

  /// Create Github issue into the Notre-Dame repository with the labels bugs and the platform used.
  /// The bug report will contain a [file], a description [feedbackText] and also some information about the
  /// application/device.
  Future<void> _createGithubIssue(
      GitHub github, File file, String feedbackText) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    github.issues.create(
        RepositorySlug.full("ApplETS/Notre-Dame"),
        IssueRequest(
            title: 'Issue from ${packageInfo.appName} ',
            body: " **Describe the issue** \n"
                "```$feedbackText```\n\n"
                "**Screenshot** \n"
                "![screenshot](https://github.com/ApplETS/Notre-Dame-Bug-report/blob/main/${file.path.replaceFirst('storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/', '')}?raw=true)\n\n"
                "**Device Infos** \n"
                "- **Version:** ${packageInfo.version} \n"
                "- **Build number:** ${packageInfo.buildNumber} \n"
                "- **Platform operating system:** ${Platform.operatingSystem} \n"
                "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n",
            labels: ['bug', 'platform: ${Platform.operatingSystem}']));
  }

  /// Upload a file to the ApplETS/Notre-Dame-Bug-report repository
  void _uploadFileToGithub(GitHub github, File file) {
    github.repositories.createFile(
        RepositorySlug.full('ApplETS/Notre-Dame-Bug-report'),
        CreateFile(
            path: file.path.replaceFirst(
                'storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/',
                ''),
            content: base64Encode(file.readAsBytesSync()).toString(),
            message: DateTime.now().toString(),
            committer:
                CommitUser('clubapplets-server', 'clubapplets@gmail.com'),
            branch: 'main'));
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

  void startDiscovery(BuildContext context) {
    List<String> ids =
        discoveryIds(AppIntl.of(context)).map((e) => e.featureId).toList();

    FeatureDiscovery.clearPreferences(context, ids);
    FeatureDiscovery.discoverFeatures(
      context,
      ids,
    );
  }
}
