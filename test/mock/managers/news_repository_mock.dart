// Package imports:
import 'package:ets_api_clients/exceptions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/news.dart';
import 'news_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<NewsRepository>()])
class NewsRepositoryMock extends MockNewsRepository {
  /// Stub the getter [news] of [mock] when called will return [toReturn].
  static void stubNews(NewsRepositoryMock mock,
      {List<News> toReturn = const []}) {
    when(mock.news).thenReturn(toReturn);
  }

  /// Stub the function [getNews] of [mock] when called will return [toReturn].
  static void stubGetNews(NewsRepositoryMock mock,
      {List<News> toReturn = const [], bool fromCacheOnly = false}) {
    when(mock.getNews(fromCacheOnly: fromCacheOnly))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getNews] of [mock] when called will throw [toThrow].
  static void stubGetNewsException(NewsRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'),
      bool fromCacheOnly = false}) {
    when(mock.getNews(fromCacheOnly: fromCacheOnly)).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [fetchAuthorNewsFromAPI] of [mock] when called will return [toReturn].
  static void stubFetchAuthorNewsFromAPI(NewsRepositoryMock mock, int authorId,
      {List<News> toReturn = const []}) {
    when(mock.fetchAuthorNewsFromAPI(authorId))
        .thenAnswer((_) async => Future.value(toReturn));
  }
}
