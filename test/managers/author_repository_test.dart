// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/models/author.dart';

// Project imports:
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
      final Author fetchedAuthor = await repository.fetchAuthorFromAPI(1);

      expect(repository.author, equals(fetchedAuthor));
    });
  });
}
