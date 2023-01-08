// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/core/models/feedback_issue.dart';

// SERVICES
import 'package:notredame/core/services/github_api.dart';

/// Mock for the [GithubApi]
class GithubApiMock extends Mock implements GithubApi {
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
