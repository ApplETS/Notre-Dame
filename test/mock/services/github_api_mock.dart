// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/models/feedback_issue.dart';
import 'package:notredame/core/services/github_api.dart';

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
}
