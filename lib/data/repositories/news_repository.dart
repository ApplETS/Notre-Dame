// Project imports:
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/data/models/hello/paginated_news.dart';
import 'package:notredame/locator.dart';

/// Repository to access all the news
class NewsRepository {
  static const String tag = "NewsRepository";

  final HelloService _helloApiClient = locator<HelloService>();

  /// Get and update the list of news.
  /// After fetching the news from the [?] the [CacheService]
  /// is updated with the latest version of the news.
  Future<PaginatedNews?> getNews(
      {int pageNumber = 1,
      int pageSize = 3,
      String? organizerId,
      String? title}) async {
    final PaginatedNews pagination = await _helloApiClient.getEvents(
        pageNumber: pageNumber,
        pageSize: pageSize,
        organizerId: organizerId,
        title: title);
    return pagination;
  }
}
