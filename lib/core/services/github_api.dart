// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:github/github.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_config/flutter_config.dart';

// SERVICES
import 'package:notredame/core/services/internal_info_service.dart';

// OTHERS
import 'package:notredame/locator.dart';

class GithubApi {
  static const String tag = "GithubApi";
  static const String tagError = "$tag - Error";

  static const String _envVariableGithubAPIKey = "GH_API_TOKEN";
  static const String _repositorySlug = "ApplETS/Notre-Dame";
  static const String _repositoryReportSlug = "ApplETS/Notre-Dame-Bug-report";

  GitHub _github;

  final InternalInfoService _internalInfoService =
      locator<InternalInfoService>();

  GithubApi() {
    String githubApiToken;
    if (kDebugMode) {
      githubApiToken = FlutterConfig.get(_envVariableGithubAPIKey).toString();
    } else {
      githubApiToken = const String.fromEnvironment(_envVariableGithubAPIKey);
    }
    _github = GitHub(auth: Authentication.withToken(githubApiToken));
  }

  /// Upload a file to the ApplETS/Notre-Dame-Bug-report repository
  void uploadFileToGithub({@required String filePath, @required File file}) {
    _github.repositories.createFile(
        RepositorySlug.full(_repositoryReportSlug),
        CreateFile(
            path: filePath,
            content: base64Encode(file.readAsBytesSync()).toString(),
            message: DateTime.now().toString(),
            committer:
                CommitUser('clubapplets-server', 'clubapplets@gmail.com'),
            branch: 'main'));
  }

  /// Create Github issue into the Notre-Dame repository with the labels bugs and the platform used.
  /// The bug report will contain a file, a description [feedbackText] and also some information about the
  /// application/device.
  Future<void> createGithubIssue(
      {@required String feedbackText, @required String fileName}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _github.issues.create(
        RepositorySlug.full(_repositorySlug),
        IssueRequest(
            title: 'Issue from ${packageInfo.appName} ',
            body: " **Describe the issue** \n"
                "```$feedbackText```\n\n"
                "**Screenshot** \n"
                "![screenshot](https://github.com/$_repositoryReportSlug/blob/main/$fileName?raw=true)\n\n"
                "${await _internalInfoService.getDeviceInfoForErrorReporting()}",
            labels: ['bug', 'platform: ${Platform.operatingSystem}']));
  }

  /// Create an empty bug picture in the local storage
  Future<File> get localFile async {
    final path = await _localPath;
    final now = DateTime.now();
    return File('$path/bugPicture-${now.hashCode}.png');
  }

  /// Get local storage path
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory.path.replaceFirst('/', '');
  }
}
