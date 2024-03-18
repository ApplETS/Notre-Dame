// Flutter imports:
import 'package:ets_api_clients/clients.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/locator.dart';

/// Repository to access all the news
class NewsRepository {
  static const String tag = "NewsRepository";

  final HelloAPIClient _helloApiClient = locator<HelloAPIClient>();

  /// Get and update the list of news.
  /// After fetching the news from the [?] the [CacheManager]
  /// is updated with the latest version of the news.
  Future<PaginatedNews?> getNews({int pageNumber = 1, int pageSize = 3}) async {
    final PaginatedNews pagination = await _helloApiClient.getEvents(
        pageNumber: pageNumber, pageSize: pageSize);
    return pagination;
  }
}
