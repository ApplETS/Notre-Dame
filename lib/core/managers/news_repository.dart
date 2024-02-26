// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:ets_api_clients/clients.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';
import 'package:ets_api_clients/models.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/utils/cache_exception.dart';
import 'package:notredame/locator.dart';

/// Repository to access all the news
class NewsRepository {
  static const String tag = "NewsRepository";

  @visibleForTesting
  static const String newsCacheKey = "newsCache";

  final Logger _logger = locator<Logger>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Used to verify if the user has connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  final HelloAPIClient _helloApiClient = locator<HelloAPIClient>();

  /// List of the news
  List<News>? _news = [
    News(
      id: "1",
      title: "Annonce #1",
      content: "Salut voici un super évènement qui pourrait vous intéressé!",
      imageThumbnail: "",
      state: 16,
      publicationDate: DateTime.now().subtract(const Duration(days: 1)),
      eventStartDate: DateTime.now().add(const Duration(days: 1, hours: 1)),
      eventEndDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      moderator: NewsUser(
        id: "1",
        name: "John Doe",
        email: "mont.samuel@outlook.com",
        type: "moderator",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      organizer: NewsUser(
        id: "1",
        name: "ApplETS",
        email: "mont.samuel@outlook.com",
        type: "organizer",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    )
  ];
  List<News>? get news => _news;

  /// Get and update the list of news.
  /// After fetching the news from the [?] the [CacheManager]
  /// is updated with the latest version of the news.
  Future<List<News>?> getNews(
      {int pageNumber = 1,
      int pageSize = 20,
      bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

    // Load the news from the cache if the list doesn't exist
    if (_news == null) {
      await getNewsFromCache();
    }

    if (fromCacheOnly) {
      return _news;
    }

    final List<News> fetchedNews = await _helloApiClient.getEvents(
        pageNumber: pageNumber, pageSize: pageSize);

    _news ??= [];

    // Update the list of news to avoid duplicate news
    for (final News news in fetchedNews) {
      if (_news?.contains(news) ?? false) {
        _news?.add(news);
      }
    }

    try {
      // Update cache
      _cacheManager.update(newsCacheKey, jsonEncode(_news));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getNews: exception raised will trying to update the cache.");
    }

    return _news;
  }

  Future<void> getNewsFromCache() async {
    _news = [];
    try {
      final List responseCache =
          jsonDecode(await _cacheManager.get(newsCacheKey)) as List<dynamic>;

      // Build list of news loaded from the cache.
      _news = responseCache
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList();

      _logger.d(
          "$tag - getNewsFromCache: ${_news?.length} news loaded from cache");
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getNewsFromCache: exception raised will trying to load news from cache.");
    }
  }

  // TODO : Fetch news from the API
  List<News> fetchNewsFromAPI(int pageNumber, int pageSize) {
    final List<News> fetchedNews = [];

    _logger.d("$tag - getNews: fetched ${fetchedNews.length} news.");

    return fetchedNews;
  }
}
