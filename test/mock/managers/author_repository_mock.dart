// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/models/author.dart';
import 'author_repository_mock.mocks.dart';

// Project imports:

@GenerateNiceMocks([MockSpec<AuthorRepository>()])
class AuthorRepositoryMock extends MockAuthorRepository {
  /// Stub the getter [author] of [mock] when called will return [toReturn].
  static void stubAuthor(AuthorRepositoryMock mock, Author toReturn) {
    when(mock.author).thenReturn(toReturn);
  }

  /// Stub the [fetchAuthorFromAPI] of [mock] when called will return [toReturn].
  static void stubFetchAuthorFromAPI(
      AuthorRepositoryMock mock, int authorId, Author toReturn) {
    when(mock.fetchAuthorFromAPI(authorId))
        .thenAnswer((_) => Future.value(toReturn));
  }
}
