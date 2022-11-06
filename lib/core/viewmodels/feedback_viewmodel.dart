// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github/github.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/models/feedback_issue.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/feedback_type.dart';

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

  List<FeedbackIssue> _myIssues = [];

  // get the list of issues
  List<FeedbackIssue> get myIssues => _myIssues;

  FeedbackViewModel({@required AppIntl intl}) : _appIntl = intl;

  /// Create a Github issue with [feedbackText] and the screenshot associated.
  Future<void> sendFeedback(String feedbackText, Uint8List feedbackScreenshot, FeedbackType type, String email) async {
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
        feedbackType: type.name,
        email: email);

    if (issue != null) {
      setBusy(true);
      _myIssues.add(FeedbackIssue(issue));
      // Sort by state open first and by number descending
      _myIssues.sort(
          (a, b) => b.state.compareTo(a.state) * 1000 + b.number - a.number);
      setBusy(false);
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
    final String issuesString =
        await _preferencesService.getString(PreferencesFlag.ghIssues);

    // If there is no issues, return 0
    if (issuesString == null || issuesString.isEmpty) {
      return 0;
    }

    // Split the issues number
    final List<String> issuesNumberList = issuesString.split(',');

    // To integers instead of String and fetch it
    _myIssues = await _githubApi.fetchIssuesByNumbers(
        issuesNumberList.map((e) => int.parse(e)).toList(), _appIntl);
    // Sort by state open first and by number descending
    _myIssues.sort(
        (a, b) => b.state.compareTo(a.state) * 1000 + b.number - a.number);

    return _myIssues.length;
  }
}
