// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class GithubApi {
  static const String tag = "GithubApi";
  static const String tagError = "$tag - Error";

  static const String _envVariableGithubAPIKey = "GITHUB_API_TOKEN";
  static const String _repositorySlug = "ApplETS/Notre-Dame";
  static const String _repositoryReportSlug = "ApplETS/Notre-Dame-Bug-report";

  GitHub _github;

  GithubApi() {
    const String githubApiToken =
        String.fromEnvironment(_envVariableGithubAPIKey);
    _github = GitHub(auth: Authentication.withToken(githubApiToken));
  }

  /// Upload a file to the ApplETS/Notre-Dame-Bug-report repository
  void uploadFileToGithub({@required String filePath, @required File file}) {
    _github.repositories.createFile(
        RepositorySlug.full(_repositoryReportSlug),
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
                "**Device Infos** \n"
                "- **Version:** ${packageInfo.version} \n"
                "- **Build number:** ${packageInfo.buildNumber} \n"
                "- **Platform operating system:** ${Platform.operatingSystem} \n"
                "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n",
            labels: ['bug', 'platform: ${Platform.operatingSystem}']));
  }

  /// Create empty picture
  Future<File> get localFile async {
    final path = await _localPath;
    final now = DateTime.now();
    return File('$path/bugPicture-${now.hashCode}.png');
  }

  /// Get local storage path
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path.replaceFirst('/', '');
  }
}
