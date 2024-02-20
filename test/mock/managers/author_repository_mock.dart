// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/models/author.dart';

import 'author_repository_mock.mocks.dart';

// Project imports:

@GenerateNiceMocks([MockSpec<AuthorRepository>()])
class AuthorRepositoryMock extends MockAuthorRepository {
  /// Stub the getter [author] of [mock] when called will return [toReturn].
  static void stubFetchAuthorFromAPI(
      AuthorRepositoryMock mock, Author toReturn) {
    when(mock.author).thenReturn(toReturn);
  }
}
