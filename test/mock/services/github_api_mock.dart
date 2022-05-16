// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:notredame/core/services/github_api.dart';

/// Mock for the [GithubApi]
class GithubApiMock extends Mock implements GithubApi {
  /// Stub the localFile of propertie [localFile] and return [fileToReturn].
  static void stubLocalFile(GithubApiMock client, File fileToReturn) {
    when(client.localFile).thenAnswer((_) async => fileToReturn);
  }
}
