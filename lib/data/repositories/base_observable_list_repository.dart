import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:github/github.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/locator.dart';
import 'package:retry/retry.dart';
import 'package:synchronized/synchronized.dart';

class BaseObservableListRepository<T> {
  static const Duration _cacheDuration = Duration(minutes: 2);

  @protected
  final secureStorage = locator<FlutterSecureStorage>();
  final _logger = locator<Logger>();

  final _items = mobx.ObservableList<T>();
  mobx.Listenable<mobx.ListChange<T>> get itemsListenable => _items;

  final Lock itemsLock = Lock();
  final String _cacheKey;

  DateTime? _cacheTimestamp;
  bool _requestInProgress = false;
  

  BaseObservableListRepository(this._cacheKey);
  @protected
  Future<String?> getFromCache(T Function(Map<String, dynamic>) fromJson) async {
    final cache = await secureStorage.read(key: _cacheKey);

    if(cache == null) {
      return null;
    }

    final List<dynamic> jsonList = json.decode(cache) as List<dynamic>;
    final cachedObjects = jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();

    await itemsLock.synchronized(() async {
      if(_items.isEmpty) {
        _items.addAll(cachedObjects);
      }
    });
    return null;
  }

  @protected
  Future<String?> getFromApi(Future<SignetsApiResponse<List<T>>> Function() apiCall, {bool forceUpdate = false}) async {
    if(_requestInProgress) {
      return null;
    }

    if(!forceUpdate) {
      final now = DateTime.now();
      if(_cacheTimestamp != null && now.difference(_cacheTimestamp!) < _cacheDuration) {
        return null;
      }
    }
    

    _requestInProgress = true;
    final apiResponse = await retry(
      () => apiCall().timeout(Duration(seconds: 3)),
      maxAttempts: 3,
      retryIf: (e) async {
        _logger.e('Error while fetching data from API: $_cacheKey', error: e);

        if (e is DioException) {
          if(e.response?.statusCode == StatusCodes.UNAUTHORIZED) {
            final authService = locator<AuthService>();
            await authService.getToken();
          }
        }
        return true;
      },
    );
    _requestInProgress = false;

    if(apiResponse.error != null && apiResponse.error!.isNotEmpty) {
      return apiResponse.error;
    }

    await itemsLock.synchronized(() async {
      _items.clear();
      _cacheTimestamp = DateTime.now();
      _items.addAll(apiResponse.data!);
    });
    await secureStorage.write(key: _cacheKey, value: json.encode(apiResponse.data));

    return null;
  }


}