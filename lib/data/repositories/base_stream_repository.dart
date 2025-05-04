import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github/github.dart';
import 'package:logger/logger.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/locator.dart';
import 'package:retry/retry.dart';
import 'package:synchronized/synchronized.dart';

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
      if(value != null) {
        _controller.add(value);
      }
    };
  }

  @protected
  Future<bool> getFromCache<RType>(RType Function(Map<String, dynamic>) fromJson) async {
    if(value != null) {
      return false;
    }

    final cache = await secureStorage.read(key: _cacheKey);
    if(cache == null || cache.isEmpty) {
      return false;
    }

    try {
      final decoded = json.decode(cache);

      await _itemsLock.synchronized(() async {
        if(decoded is List) {
          value ??= decoded.map<RType>((e) => fromJson(e as Map<String, dynamic>)).toList() as T;
        } else if (decoded is Map<String, dynamic>) {
          value ??= fromJson(decoded) as T;
        }
        _controller.add(value);
      });
      return true;
    } catch(e) {
      _logger.e('Error while reading from cache: $_cacheKey', error: Exception);
      _controller.addError(e);
      return false;
    }

  }

  @protected
  Future<bool> getFromApi(Future<SignetsApiResponse<T>> Function() apiCall, {bool forceUpdate = false}) async {
    if(_requestInProgress) {
      return false;
    }

    if(!forceUpdate) {
      final now = DateTime.now();
      if(_cacheTimestamp != null && now.difference(_cacheTimestamp!) < _cacheDuration) {
        return false;
      }
    }

    try {
      _requestInProgress = true;
      final apiResponse = await retry(
        () => apiCall().timeout(Duration(seconds: 3)),
        maxAttempts: 5,
        retryIf: (e) async {
          _logger.e('Error while fetching data from API: $_cacheKey', error: e);

          if(e is DioException && e.response?.statusCode == StatusCodes.UNAUTHORIZED) {
            final authService = locator<AuthService>();
            await authService.getToken();
          }
          return true;
        },
      );
      _requestInProgress = false;

      if(apiResponse.error != null && apiResponse.error!.isNotEmpty) {
        _controller.addError(apiResponse.error as Object);
        _logger.e('Error while fetching data from API', error: apiResponse.error);
        return false;
      }

      await _itemsLock.synchronized(() async {
        _cacheTimestamp = DateTime.now();
        value = apiResponse.data;
        _controller.add(value);
      });
      await secureStorage.write(key: _cacheKey, value: json.encode(apiResponse.data));
      return true;
    } catch(e) {
      _logger.e('Error while fetching data from API: $_cacheKey', error: e);
      _controller.addError(e);
      return false;
    } finally {
      _requestInProgress = false;
    }
    
  }
}