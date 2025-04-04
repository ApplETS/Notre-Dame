// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/hello/organizer.dart';
import 'package:notredame/data/repositories/author_repository.dart';
import 'author_repository_mock.mocks.dart';

// Project imports:

@GenerateNiceMocks([MockSpec<AuthorRepository>()])
class AuthorRepositoryMock extends MockAuthorRepository {
  /// Stub the getter [author] of [mock] when called will return [toReturn].
  static void stubGetOrganizer(AuthorRepositoryMock mock, String organizerId, Organizer toReturn) {
    when(mock.getOrganizer(organizerId)).thenAnswer((_) async => toReturn);
  }
}
