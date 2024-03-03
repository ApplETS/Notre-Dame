// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/models/news.dart';
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

  /// List of the news with 3 test news.
  List<News>? _news = <News>[
    News(
      id: 1,
      title: "Merci à McGill Robotics pour l’invitation au RoboHacks 2023!",
      description:
          "Le club scientifique qui conceptualise un robot de recherche et secourisme recrute pour ses nouveaux projets! Une rencontre d’information est prévue le mercredi 13 octobre 2021 à 17h au local D-5023.Viens nous rencontrer pour en savoir plus sur notre prochaine mission de secourisme et faire partie de l’équipe!Le club scientifique qui conceptualise un robot de recherche et secourisme recrute pour ses nouveaux projets! Une rencontre d’information est prévue le mercredi 13 octobre 2021 à 17h au local D-5023.Viens nous rencontrer pour en savoir plus sur notre prochaine mission de secourisme et faire partie de l’équipe!Le club scientifique qui conceptualise un robot de recherche et secourisme recrute pour ses nouveaux projets! Une rencontre d’information est prévue le mercredi 13 octobre 2021 à 17h au local D-5023.Viens nous rencontrer pour en savoir plus sur notre prochaine mission de secourisme et faire partie de l’équipe!Le club scientifique qui conceptualise un robot de recherche et secourisme recrute pour ses nouveaux projets! Une rencontre d’information est prévue le mercredi 13 octobre 2021 à 17h au local D-5023.Viens nous rencontrer pour en savoir plus sur notre prochaine mission de secourisme et faire partie de l’équipe!",
      author: "Capra",
      authorId: 1,
      avatar: "https://picsum.photos/200/200",
      activity: "Club scientifique",
      publishedDate: DateTime.now(),
      eventStartDate: DateTime.now().add(const Duration(days: 2)),
      eventEndDate: DateTime.now().add(const Duration(days: 5)),
      image: "https://picsum.photos/400/200",
      tags: [
        "Robotique",
        "Programmation",
        "Intelligence artificielle",
        "Compétition",
      ],
    ),
    News(
      id: 2,
      title: "Compétition de développement mobile",
      description:
          "AMC est une compétition de développement mobile organisée par ApplETS, un club étudiant de l'ÉTS. La compétition à lieu du 27 au 28 janvier 2024. Que vous soyez un étudiant universitaire ou collégial, novice ou expérimenté en développement, cette compétition est l'occasion idéale de repousser vos limites, d'apprendre des autres et de montrer votre talent dans le monde de la technologie mobile.",
      author: "App|ETS",
      authorId: 2,
      avatar: "https://picsum.photos/200/200",
      activity: "Club scientifique",
      publishedDate: DateTime.now(),
      eventStartDate: DateTime.now().add(const Duration(days: 10)),
      eventEndDate: DateTime.now().add(const Duration(days: 11)),
      image: "https://picsum.photos/400/200",
      tags: [
        "Compétition",
        "Développement mobile",
      ],
    ),
    News(
      id: 3,
      title: "Test 3",
      description: "Test 3 description",
      author: "Jean-Guy Tremblay",
      authorId: 3,
      avatar: "https://picsum.photos/200/200",
      activity: "Service à la vie étudiante",
      publishedDate: DateTime.now(),
      eventStartDate: DateTime.now().add(const Duration(days: 3)),
      image: "https://picsum.photos/400/200",
      tags: ["5 @ 7", "Vie étudiante", "Activité"],
    ),
  ];

  List<News>? get news => _news;

  /// Get and update the list of news.
  /// After fetching the news from the [?] the [CacheManager]
  /// is updated with the latest version of the news.
  Future<List<News>?> getNews({bool fromCacheOnly = false}) async {
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

    final List<News> fetchedNews = await fetchNewsFromAPI();

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
  Future<List<News>> fetchNewsFromAPI() async {
    final List<News> fetchedNews = [];

    _logger.d("$tag - getNews: fetched ${fetchedNews.length} news.");

    return fetchedNews;
  }

  // TODO : Fetch news from the API
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
