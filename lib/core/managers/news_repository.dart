// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:ets_api_clients/clients.dart';
import 'package:flutter/material.dart';

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

  // TODO : Fetch news from the API
  Future<List<News>> fetchAuthorNewsFromAPI(int authorId) async {
    final List<News> fetchedNews = _news ?? [];

    // Filter news based on authorId
    final List<News> authorNews =
        fetchedNews.where((news) => news.authorId == authorId).toList();

    _logger.d(
        "$tag - fetchAuthorNewsFromAPI: fetched ${authorNews.length} news for author $authorId.");

    return authorNews;
  }
}
