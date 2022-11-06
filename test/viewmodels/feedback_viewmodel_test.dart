// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:github/github.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/models/feedback_issue.dart';

// CONSTANTS
import 'package:notredame/core/constants/feedback_type.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/github_api.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/feedback_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/services/github_api_mock.dart';
import '../mock/services/preferences_service_mock.dart';

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  GithubApiMock githubApiMock;

  PreferencesServiceMock preferencesServiceMock;

  AppIntl appIntl;
  FeedbackViewModel viewModel;

  group('FeedbackViewModel - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      githubApiMock = setupGithubApiMock() as GithubApiMock;
      preferencesServiceMock =
          setupPreferencesServiceMock() as PreferencesServiceMock;
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
        final File file = File('bugReportTest.png');
        GithubApiMock.stubLocalFile(githubApiMock, file);
        setupFlutterToastMock();

        await file.writeAsBytes(image.encodePng(
            image.copyResize(image.decodeImage(screenshotData), width: 307)));

        await viewModel.sendFeedback(
            'Notre-Dame bug report', screenshotData, FeedbackType.bug, null);

        verify(githubApiMock.uploadFileToGithub(
          filePath: file.path.split('/').last,
          file: file,
        ));
      });

      test('If the github issue has been created with email', () async {
        final File file = File('bugReportTest.png');
        GithubApiMock.stubLocalFile(githubApiMock, file);

        await viewModel.sendFeedback('Notre-Dame bug report', screenshotData,
            FeedbackType.bug, 'email@email.com');

        verify(githubApiMock.createGithubIssue(
            feedbackText: 'Notre-Dame bug report',
            fileName: file.path.split('/').last,
            feedbackType: 'bug',
            email: 'email@email.com'));
      });

      test('If the github issue has been created without email', () async {
        final File file = File('bugReportTest.png');
        GithubApiMock.stubLocalFile(githubApiMock, file);

        await viewModel.sendFeedback(
            'Notre-Dame bug report', screenshotData, FeedbackType.bug, null);

        verify(githubApiMock.createGithubIssue(
            feedbackText: 'Notre-Dame bug report',
            fileName: file.path.split('/').last,
            feedbackType: 'bug'));
      });
    });

    group('futureToRun - ', () {
      // Test if in the preferences there is no issues
      test('If there is no issues', () async {
        when(preferencesServiceMock.getString(PreferencesFlag.ghIssues))
            .thenAnswer((_) => Future.value(''));

        final int result = await viewModel.futureToRun();

        expect(result, 0);
      });

      // Test if in the preferences there is issues
      test('If there is issues', () async {
        when(preferencesServiceMock.getString(PreferencesFlag.ghIssues))
            .thenAnswer((_) => Future.value('1,2,3'));

        final List<FeedbackIssue> issues = [
          FeedbackIssue(Issue(
              number: 1,
              title: 'title',
              body: 'body',
              state: 'open',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              closedAt: DateTime.now(),
              user: User(
                  login: 'login', avatarUrl: 'avatarUrl', htmlUrl: 'htmlUrl'))),
          FeedbackIssue(Issue(
              number: 2,
              title: 'title',
              body: 'body',
              state: 'open',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              closedAt: DateTime.now(),
              user: User(
                  login: 'login', avatarUrl: 'avatarUrl', htmlUrl: 'htmlUrl'))),
          FeedbackIssue(Issue(
              number: 3,
              title: 'title',
              body: 'body',
              state: 'open',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              closedAt: DateTime.now(),
              user: User(
                  login: 'login', avatarUrl: 'avatarUrl', htmlUrl: 'htmlUrl'))),
        ];

        GithubApiMock.stubFetchIssuesByNumbers(githubApiMock, issues, appIntl);

        final int result = await viewModel.futureToRun();

        expect(result, 3);

        verify(preferencesServiceMock.getString(PreferencesFlag.ghIssues));

        verify(githubApiMock.fetchIssuesByNumbers([1, 2, 3], appIntl));

        expect(viewModel.myIssues, issues);
      });
    });
  });
}
