// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//SERVICE
import 'package:notredame/core/services/github_api.dart';

// OTHERS
import 'package:notredame/locator.dart';

class FeedbackViewModel extends BaseViewModel {
  /// Used to access Github functionalities
  final GithubApi _githubApi = locator<GithubApi>();

  final AppIntl _appIntl;

  final int _screenshotImageWidth = 307;

  FeedbackViewModel({@required AppIntl intl}) : _appIntl = intl;

  /// Create a Github issue with [UserFeedback] and the screenshot associated.
  Future<void> sendFeedback(UserFeedback feedback) async {
    //Generate info to pass to github
    final File file = await _githubApi.localFile;
    await file.writeAsBytes(encodeScreenshotForGithub(feedback.screenshot));

    final String fileName = file.path.split('/').last;

    // Upload the file and create the issue
    _githubApi.uploadFileToGithub(filePath: fileName, file: file);

    _githubApi.createGithubIssue(
        feedbackText: feedback.text,
        fileName: fileName,
        feedbackType: getUserFeedbackType(feedback));

    file.deleteSync();

    Fluttertoast.showToast(
      msg: _appIntl.thank_you_for_the_feedback,
      gravity: ToastGravity.CENTER,
    );
  }

  List<int> encodeScreenshotForGithub(Uint8List screenshot) {
    return image.encodePng(image.copyResize(image.decodeImage(screenshot),
        width: _screenshotImageWidth));
  }

  String getUserFeedbackType(UserFeedback userFeedback) {
    return userFeedback.extra.entries.first.value.toString().split('.').last;
  }
}
