// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/news_repository.dart';

// MODEL
import 'package:notredame/core/models/news.dart';

import '../helpers.dart';

void main() {
  group('NewsRepository tests', () {
    NewsRepository repository;

    setUp(() {
      setupLogger();
      setupAnalyticsServiceMock();
      setupCacheManagerMock();
      setupNetworkingServiceMock();
      repository = NewsRepository();
    });

    test('Fetching news updates the news list', () async {
      // TODO : remove when the news will be empty by default without test news
      //expect(repository.news, isEmpty);

      final List<News> fetchedNews = await repository.getNews(fromCacheOnly: true);

      expect(repository.news, isNotEmpty);
      expect(repository.news, equals(fetchedNews));
    });

    test('Fetching news from cache returns the correct data', () async {
      // TODO : remove when the news will be empty by default without test news
      //expect(repository.news, isEmpty);

      await repository.getNews(fromCacheOnly: true);

      final List<News> newsFromCache = await repository.getNews(fromCacheOnly: true);

      expect(newsFromCache, isNotEmpty);
      expect(newsFromCache, equals(repository.news));
    });

    test('Fetching news from API updates the news list', () async {
      // TODO : remove when the news will be empty by default without test news
      //expect(repository.news, isEmpty);

      final List<News> fetchedNews = await repository.getNews(fromCacheOnly: false);

      expect(repository.news, isNotEmpty);
      expect(repository.news, equals(fetchedNews));
    });
  });
}
