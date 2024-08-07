// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github/github.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/integration/github_api.dart';
import 'package:notredame/features/more/feedback/models/feedback_issue.dart';
import 'github_api_mock.mocks.dart';

/// Mock for the [GithubApi]
@GenerateNiceMocks([MockSpec<GithubApi>()])
class GithubApiMock extends MockGithubApi {
  /// Stub the localFile of propertie [localFile] and return [fileToReturn].
  static void stubLocalFile(GithubApiMock client, File fileToReturn) {
    when(client.localFile).thenAnswer((_) async => fileToReturn);
  }

  static void stubFetchIssuesByNumbers(
      GithubApiMock client, List<FeedbackIssue> issuesToReturn, AppIntl intl) {
    when(client.fetchIssuesByNumbers(any, any))
        .thenAnswer((_) async => Future.value(issuesToReturn));
  }

  static void stubCreateGithubIssue(GithubApiMock client, Issue toReturn) {
    when(client.createGithubIssue(
            feedbackText: anyNamed("feedbackText"),
            fileName: anyNamed("fileName"),
            feedbackType: anyNamed("feedbackType"),
            email: anyNamed("email")))
        .thenAnswer((_) async => Future.value(toReturn));
  }
}
