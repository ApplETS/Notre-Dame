// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as lib;

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/cache_exception.dart';

/// Abstraction of the cache management system.
class CacheService {
  static const String tag = "CacheManager";

  /// Name of the cache.
  static const key = 'ETSMobileCache';

  final lib.CacheManager _cacheManager = lib.CacheManager(
    lib.Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 20,
      repo: lib.CacheObjectProvider(databaseName: key),
    ),
  );

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Get from the cache the value associated with [key].
  /// Throw a [CacheException] if the [key] doesn't exist.
  Future<String> get(String key) async {
    final lib.FileInfo? fileInfo = await _cacheManager.getFileFromCache(key);

    if (fileInfo == null) {
      _analyticsService.logEvent(tag, "Trying to access $key from the cache but file doesn't exists");
      throw CacheException(prefix: tag, message: "$key doesn't exist in the cache");
    }

    return fileInfo.file.readAsString();
  }

  /// Update/create in the cache the value associated with [key].
  Future update(String key, String value) async {
    try {
      await _cacheManager.putFile(key, UriData.fromString(value, encoding: utf8).contentAsBytes());
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, "Exception raised during cache update of $key: $e", e, stacktrace);
      rethrow;
    }
  }

  /// Delete from the cache the content associated with [key].
  Future delete(String key) async {
    try {
      await _cacheManager.removeFile(key);
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, "Exception raised during cache delete of $key: $e", e, stacktrace);
    }
  }

  /// Empty the cache
  Future empty() async {
    try {
      await _cacheManager.emptyCache();
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, "Exception raised during emptying cache: $e", e, stacktrace);
      rethrow;
    }
  }
}
