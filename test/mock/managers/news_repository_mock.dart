// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/utils/api_exception.dart';
import 'news_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<NewsRepository>()])
class NewsRepositoryMock extends MockNewsRepository {
  /// Stub the function [getNews] of [mock] when called will return [toReturn].
  static void stubGetNews(NewsRepositoryMock mock,
      {PaginatedNews? toReturn, int pageNumber = 1, int pageSize = 3}) {
    when(mock.getNews(pageNumber: pageNumber, pageSize: pageSize))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getNews] of [mock] when called will return [toReturn].
  static void stubGetNewsOrganizer(NewsRepositoryMock mock, String organizerId,
      {PaginatedNews? toReturn, int pageNumber = 1, int pageSize = 3}) {
    when(mock.getNews(
            pageNumber: pageNumber,
            pageSize: pageSize,
            organizerId: organizerId))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getNews] of [mock] when called will throw [toThrow].
  static void stubGetNewsException(NewsRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException'),
      int pageNumber = 1,
      int pageSize = 3}) {
    when(mock.getNews(pageNumber: pageNumber, pageSize: pageSize)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }
}
