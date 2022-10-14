// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:github/github.dart';
import 'package:logger/logger.dart';
import 'package:notredame/core/models/feedback_issue.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_config/flutter_config.dart';

// SERVICES
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// OTHERS
import 'package:notredame/locator.dart';

class GithubApi {
  static const String tag = "GithubApi";
  static const String tagError = "$tag - Error";

  static const String _envVariableGithubAPIKey = "GH_API_TOKEN";
  static const String _repositorySlug = "ApplETS/Notre-Dame";
  static const String _repositoryReportSlug = "ApplETS/Notre-Dame-Bug-report";

  GitHub _github;

  final Logger _logger = locator<Logger>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final InternalInfoService _internalInfoService =
      locator<InternalInfoService>();

  GithubApi() {
    String githubApiToken;
    if (kDebugMode &&
        FlutterConfig.variables.containsKey(_envVariableGithubAPIKey)) {
      githubApiToken = FlutterConfig.get(_envVariableGithubAPIKey).toString();
    } else {
      githubApiToken = const String.fromEnvironment(_envVariableGithubAPIKey);
    }
    _github = GitHub(auth: Authentication.withToken(githubApiToken));
  }

  /// Upload a file to the ApplETS/Notre-Dame-Bug-report repository
  void uploadFileToGithub({@required String filePath, @required File file}) {
    _github.repositories
        .createFile(
            RepositorySlug.full(_repositoryReportSlug),
            CreateFile(
                path: filePath,
                content: base64Encode(file.readAsBytesSync()),
                message: DateTime.now().toString(),
                committer:
                    CommitUser('clubapplets-server', 'clubapplets@gmail.com'),
                branch: 'main'))
        .catchError((error) {
      // ignore: avoid_dynamic_calls
      _logger.e("uploadFileToGithub error: ${error.message}");
      _analyticsService.logError(
          tag,
          // ignore: avoid_dynamic_calls
          "uploadFileToGithub: ${error.message}",
          error as GitHubError);
    });
  }

  /// Create Github issue into the Notre-Dame repository with the labels bugs and the platform used.
  /// The bug report will contain a file, a description [feedbackText] and also some information about the
  /// application/device.
  Future<Issue> createGithubIssue(
      {@required String feedbackText,
      @required String fileName,
      @required String feedbackType}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return _github.issues
        .create(
            RepositorySlug.full(_repositorySlug),
            IssueRequest(
                title: 'Issue from ${packageInfo.appName} ',
                body: " **Describe the issue** \n"
                    "```$feedbackText```\n\n"
                    "**Screenshot** \n"
                    "![screenshot](https://github.com/$_repositoryReportSlug/blob/main/$fileName?raw=true)\n\n"
                    "${await _internalInfoService.getDeviceInfoForErrorReporting()}",
                labels: [
                  feedbackType,
                  'platform: ${Platform.operatingSystem}'
                ]))
        .catchError((error) {
      // ignore: avoid_dynamic_calls
      _logger.e("createGithubIssue error: ${error.message}");
      _analyticsService.logError(
          tag,
          // ignore: avoid_dynamic_calls
          "createGithubIssue: ${error.message}",
          error as GitHubError);
    });
  }

  Future<List<FeedbackIssue>> fetchIssuesByNumbers(
      List<int> numbers, AppIntl appIntl) async {
    final List<FeedbackIssue> issues = [];
    for (int i = 0; i < numbers.length; i++) {
      issues.add(FeedbackIssue(await _github.issues
          .get(RepositorySlug.full(_repositorySlug), numbers[i])
          .catchError((error) {
        // ignore: avoid_dynamic_calls
        _logger.e("fetchIssuesByNumbers error: ${error.message}");
        _analyticsService.logError(
            tag,
            // ignore: avoid_dynamic_calls
            "fetchIssuesByNumbers: ${error.message}",
            error as GitHubError);
      })));
    }
    return issues;
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
