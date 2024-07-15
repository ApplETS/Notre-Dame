// Project imports:
import 'package:notredame/features/app/storage/cache_manager.dart';
import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/ets/events/api-client/models/paginated_news.dart';
import 'package:notredame/utils/locator.dart';

/// Repository to access all the news
class NewsRepository {
  static const String tag = "NewsRepository";

  final HelloAPIClient _helloApiClient = locator<HelloAPIClient>();

  /// Get and update the list of news.
  /// After fetching the news from the [?] the [CacheManager]
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
