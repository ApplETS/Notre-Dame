// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/models/author.dart';
import '../helpers.dart';

void main() {
  group('AuthorRepository tests', () {
    late AuthorRepository repository;

    setUp(() {
      setupLogger();
      setupAnalyticsServiceMock();
      setupCacheManagerMock();
      setupNetworkingServiceMock();
      repository = AuthorRepository();
    });

    test('Fetching author updates the author', () async {
      final Author fetchedAuthor = repository.fetchAuthorFromAPI("");

      expect(repository.author, equals(fetchedAuthor));
    });
  });
}
