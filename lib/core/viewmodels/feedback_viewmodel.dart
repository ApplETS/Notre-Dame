// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
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

    _githubApi.createGithubIssue(
        feedbackText: feedbackText,
        fileName: fileName,
        feedbackType: feedbackType);

    file.deleteSync();
    Fluttertoast.showToast(
      msg: _appIntl.thank_you_for_the_feedback,
      gravity: ToastGravity.CENTER,
    );
  }
}
