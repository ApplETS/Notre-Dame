// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/github_api.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/services/github_api_mock.dart';

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  GithubApiMock githubApiMock;

  AppIntl appIntl;
  FeedbackViewModel viewModel;
  const feedBackText = 'Notre-Dame bug report';
  final file = File('bugReportTest.png');
  final filePath = file.path.split('/').last;
  final Map<String, dynamic> extra = {'': 'bugReport'};

  String getUserFeedbackType() {
    return extra.entries.first.value.toString().split('.').last;
  }

  group('FeedbackViewModel - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      githubApiMock = setupGithubApiMock() as GithubApiMock;
      appIntl = await setupAppIntl();
      setupLogger();

      viewModel = FeedbackViewModel(intl: appIntl);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<GithubApi>();
    });

    group('sendFeedback - ', () {
      Uint8List screenshotData;

      setUp(() async {
        final ByteData bytes = await rootBundle
            .load('packages/notredame/assets/images/ets_red_logo.png');
        screenshotData = bytes.buffer.asUint8List();
      });

      test('If the file uploaded matches', () async {
        GithubApiMock.stubLocalFile(githubApiMock, file);
        setupFlutterToastMock();

        await file.writeAsBytes(image.encodePng(
            image.copyResize(image.decodeImage(screenshotData), width: 307)));

        await viewModel.sendFeedback(UserFeedback(
            text: feedBackText, screenshot: screenshotData, extra: extra));

        verify(githubApiMock.uploadFileToGithub(
          filePath: filePath,
          file: file,
        ));
      });

      test('If the github issue has been created', () async {
        GithubApiMock.stubLocalFile(githubApiMock, file);

        await viewModel.sendFeedback(UserFeedback(
            text: feedBackText, screenshot: screenshotData, extra: extra));

        verify(githubApiMock.createGithubIssue(
            feedbackText: feedBackText,
            fileName: filePath,
            feedbackType: getUserFeedbackType()));
      });
    });
  });
}
