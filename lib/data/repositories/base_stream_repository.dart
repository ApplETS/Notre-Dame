// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github/github.dart';
import 'package:logger/logger.dart';
import 'package:retry/retry.dart';
import 'package:synchronized/synchronized.dart';

// Project imports:
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/locator.dart';

class BaseStreamRepository<T> {
  static const Duration _cacheDuration = Duration(minutes: 2);

  @protected
  final secureStorage = locator<FlutterSecureStorage>();
  final _logger = locator<Logger>();

  @protected
  T? value;

  final Lock _itemsLock = Lock();
  final String _cacheKey;
  final _controller = StreamController<T?>.broadcast();
  Stream<T?> get stream => _controller.stream;

  DateTime? _cacheTimestamp;
  bool _requestInProgress = false;

  BaseStreamRepository(this._cacheKey) {
    _controller.onListen = () {
      if (value != null) {
        _controller.add(value);
      }
    };
  }

  bool _isFirstFetch = true;
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Checks if the cache is still valid based on the timestamp and the defined duration.
  bool _isCacheValid() {
    if (_cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Helper that decodes the data from JSON and sets the [value] property, applying an optional filter before emitting through the controller.
  Future<void> _setValueFromJson<RType>(
      dynamic decoded,
      RType Function(Map<String, dynamic>) fromJson, {
      T Function(T)? filter,
  }) async {
    await _itemsLock.synchronized(() async {
      if (decoded is List) {
        value ??= decoded.map<RType>((e) => fromJson(e as Map<String, dynamic>)).toList() as T;
      } else if (decoded is Map<String, dynamic>) {
        value ??= fromJson(decoded) as T;
      }
      final T? toEmit = filter != null && value != null ? filter(value as T) : value;
      _controller.add(toEmit);
    });
  }

  /// Helper that performs the API call with retry logic and error handling.
  Future<SignetsApiResponse<T>> _performApiCall(Future<SignetsApiResponse<T>> Function() apiCall) async {
    return await retry(
      () => apiCall().timeout(Duration(seconds: 3)),
      maxAttempts: 5,
      retryIf: (e) async {
        _logger.e('Error while fetching data from API: $_cacheKey', error: e);
        if (e is DioException && e.response?.statusCode == StatusCodes.UNAUTHORIZED) {
          final authService = locator<AuthService>();
          await authService.getToken();
        }
        return true;
      },
    );
  }

  /// Fetch data either from cache or from the API.
  ///
  /// The optional [filterApiCached] callback is applied to any data that is emitted
  /// through the controller and before writing into secure storage. This is
  /// used by callers who want to restrict the result set (for example
  /// filtering a list of activities by date range) without touching the
  /// underlying storage logic.
  ///
  /// The optional [filterEmittedCache] callback is applied to any data that is emitted
  /// from cache. This is used by callers who want to further filter cached data
  /// (for example, filtering a list of activities by date range) without touching the
  /// underlying storage logic.
  Future<void> fetch<RType>(
    Future<SignetsApiResponse<T>> Function() apiCall,
    RType Function(Map<String, dynamic>) fromJson, {
    bool forceUpdate = false,
    T Function(T)? filterApiCached,
    T Function(T)? filterEmittedCache
  }) async {
    if (_isFirstFetch) {
      _isFirstFetch = false;

      await Future.wait([
        getFromCache(fromJson, filterCache: filterEmittedCache),
        getFromApi(apiCall, forceUpdate: true, filter: filterApiCached)
      ]);
    } else {
      if (!forceUpdate && _isCacheValid() && value != null) {
        return;
      } else {
        await getFromApi(apiCall, forceUpdate: true, filter: filterApiCached);
      }
    }
  }

  @protected
  Future<void> getFromCache<RType>(
      RType Function(Map<String, dynamic>) fromJson, {
      T Function(T)? filterCache,
  }) async {
    if (value != null) {
      return;
    }

    final cache = await secureStorage.read(key: _cacheKey);
    if (cache == null || cache.isEmpty) {
      return;
    }

    try {
      final decoded = json.decode(cache);
      await _setValueFromJson(decoded, fromJson, filter: filterCache);
    } catch (e) {
      _logger.e('Error while reading from cache: $_cacheKey', error: e);
      _controller.addError(e);
    }
  }

  @protected
  Future<void> getFromApi(
      Future<SignetsApiResponse<T>> Function() apiCall,
      {bool forceUpdate = false,
      T Function(T)? filter
  }) async {
    if (_requestInProgress) {
      return;
    }

    if (!forceUpdate && _isCacheValid()) {
      return;
    }

    if (!await _networkingService.hasConnectivity()) {
      _controller.addError('No internet connection');
      return;
    }

    try {
      _requestInProgress = true;
      final apiResponse = await _performApiCall(apiCall);
      _requestInProgress = false;

      if (apiResponse.error != null && apiResponse.error!.isNotEmpty) {
        _controller.addError(apiResponse.error as Object);
        _logger.e('Error while fetching data from API', error: apiResponse.error);
        return;
      }

      // Apply filter to the raw data before writing to storage.
      final T? dataToCache = filter != null && apiResponse.data != null ? filter(apiResponse.data as T) : apiResponse.data;

      await _itemsLock.synchronized(() async {
        _cacheTimestamp = DateTime.now();
        _controller.add(apiResponse.data);
      });
      await secureStorage.write(key: _cacheKey, value: json.encode(dataToCache));
    } catch (e) {
      _logger.e('Error while fetching data from API: $_cacheKey', error: e);
      _controller.addError(e);
    } finally {
      _requestInProgress = false;
    }
  }
}
