// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/news.dart';
import '../helpers.dart';

void main() {
  group('NewsRepository tests', () {
    late NewsRepository repository;

    setUp(() {
      setupLogger();
      setupAnalyticsServiceMock();
      setupCacheManagerMock();
      setupNetworkingServiceMock();
      repository = NewsRepository();
    });

    test('Fetching news updates the news list', () async {
      final List<News>? fetchedNews =
          await repository.getNews(fromCacheOnly: true);

      expect(repository.news, isNotEmpty);
      expect(repository.news, equals(fetchedNews));
    });

    test('Fetching news from cache returns the correct data', () async {
      await repository.getNews(fromCacheOnly: true);

      final List<News>? newsFromCache =
          await repository.getNews(fromCacheOnly: true);

      expect(newsFromCache, isNotEmpty);
      expect(newsFromCache, equals(repository.news));
    });

    test('Fetching news from API updates the news list', () async {
      final List<News>? fetchedNews = await repository.getNews();

      expect(repository.news, isNotEmpty);
      expect(repository.news, equals(fetchedNews));
    });

    test('Fetching news from API for a specific author', () async {
      const int authorId = 1;
      final List<News> fetchedNews =
          await repository.fetchAuthorNewsFromAPI(authorId);

      for (final news in fetchedNews) {
        expect(news.authorId, equals(authorId));
      }
    });
  });
}
