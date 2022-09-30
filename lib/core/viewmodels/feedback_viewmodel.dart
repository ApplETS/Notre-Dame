// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github/github.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//SERVICE
import 'package:notredame/core/services/github_api.dart';

// OTHERS
import 'package:notredame/locator.dart';

class FeedbackViewModel extends FutureViewModel {
  /// Used to access Github functionalities
  final GithubApi _githubApi = locator<GithubApi>();

  /// Use to get the value associated to each settings key
  final PreferencesService _preferencesService = locator<PreferencesService>();

  final AppIntl _appIntl;

  List<Issue> _myIssues = [];

  // get the list of issues
  List<Issue> get myIssues => _myIssues;

  FeedbackViewModel({@required AppIntl intl}) : _appIntl = intl;

  /// Create a Github issue with [feedbackText] and the screenshot associated.
  Future<void> sendFeedback(String feedbackText, Uint8List feedbackScreenshot,
      String feedbackType) async {
    //Generate info to pass to github
    final File file = await _githubApi.localFile;
    await file.writeAsBytes(image.encodePng(
        image.copyResize(image.decodeImage(feedbackScreenshot), width: 307)));

    final String fileName = file.path.split('/').last;

    // Upload the file and create the issue
    _githubApi.uploadFileToGithub(filePath: fileName, file: file);

    final Issue issue = await _githubApi.createGithubIssue(
        feedbackText: feedbackText,
        fileName: fileName,
        feedbackType: feedbackType);

    if (issue != null) {
      _myIssues.add(issue);
      // Save the issue number in the preferences
      _preferencesService.setString(
          PreferencesFlag.ghIssues, _myIssues.map((e) => e.number).join(','));
    }

    file.deleteSync();
    Fluttertoast.showToast(
      msg: _appIntl.thank_you_for_the_feedback,
      gravity: ToastGravity.CENTER,
    );
  }

  // @override
  @override
  Future<int> futureToRun() async {
    // Get the issues number from the preferences
    final String issues =
        await _preferencesService.getString(PreferencesFlag.ghIssues);

    // If there is no issues, return 0
    if (issues == null) {
      return 0;
    }

    // Split the issues number
    final List<String> issuesList = issues.split(',');

    // To integers instead of String and fetch it
    _myIssues = await _githubApi
        .fetchIssuesByNumbers(issuesList.map((e) => int.parse(e)).toList());

    return _myIssues.length;
  }
}
