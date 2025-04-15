// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/cache_exception.dart';

class UserRepository {
  static const String tag = "UserRepository";

  static const String usernameSecureKey = "usernameKey";
  static const String passwordSecureKey = "passwordKey";
  @visibleForTesting
  static const String infoCacheKey = "infoCache";
  @visibleForTesting
  static const String programsCacheKey = "programsCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Used to verify if the user has connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Secure storage manager to access and update the cache.
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();

  /// Cache manager to access and update the cache.
  final CacheService _cacheManager = locator<CacheService>();

  /// Used to access the Signets API
  final SignetsAPIClient _signetsApiClient = locator<SignetsAPIClient>();

  /// Information for the student profile
  ProfileStudent? _info;

  ProfileStudent? get info => _info;

  /// List of the programs for the student
  List<Program>? _programs;

  List<Program>? get programs => _programs;

  //TODO: remove when all users are on 4.58.0 or more
  /// Log out the user
  Future<bool> logOut() async {
    // Delete the credentials from the secure storage
    try {
      await _secureStorage.delete(key: usernameSecureKey);
      await _secureStorage.delete(key: passwordSecureKey);
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(tag, "Authenticate - PlatformException - $e", e, stacktrace);
      return false;
    }
    return true;
  }

  /// Check whether the user was previously authenticated.
  Future<bool> wasPreviouslyLoggedIn() async {
    try {
      final username = await _secureStorage.read(key: usernameSecureKey);
      if (username != null) {
        final password = await _secureStorage.read(key: passwordSecureKey);
        return password != null && password.isNotEmpty;
      }
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(tag, "getPassword - PlatformException - $e", e, stacktrace);
    }
    return false;
  }
  //TODO END: remove when all users are on 4.58.0 or more

  /// Get the list of programs on which the student was active.
  /// The list from the [CacheService] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<List<Program>> getPrograms({bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = !await _networkingService.hasConnectivity();
    }

    // Load the programs from the cache if the list doesn't exist
    if (_programs == null) {
      try {
        _programs = [];

        final List programsCached = jsonDecode(await _cacheManager.get(programsCacheKey)) as List<dynamic>;

        // Build list of programs loaded from the cache.
        _programs = programsCached.map((e) => Program.fromJson(e as Map<String, dynamic>)).toList();
        _logger.d("$tag - getPrograms: ${_programs!.length} programs loaded from cache.");
      } on CacheException catch (_) {
        _logger.e("$tag - getPrograms: exception raised while trying to load the programs from cache.");
      }
    }

    if (fromCacheOnly) {
      return _programs!;
    }

    try {
      _programs = await _signetsApiClient.getPrograms();
      _logger.d("$tag - getPrograms: ${_programs!.length} programs fetched.");

      // Update cache
      _cacheManager.update(programsCacheKey, jsonEncode(_programs));
    } on CacheException catch (_) {
      _logger.e("$tag - getPrograms: exception raised while trying to update the cache.");
      return _programs!;
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, "Exception raised during getPrograms: $e", e, stacktrace);
      rethrow;
    }

    return _programs!;
  }

  /// Get the profile information.
  /// The information from the [CacheService] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<ProfileStudent?> getInfo({bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

    // Load the student profile from the cache if the information doesn't exist
    if (_info == null) {
      try {
        final infoCached = jsonDecode(await _cacheManager.get(infoCacheKey)) as Map<String, dynamic>;

        // Build info loaded from the cache.
        _info = ProfileStudent.fromJson(infoCached);
        _logger.d("$tag - getInfo: $_info info loaded from cache.");
      } on CacheException catch (e) {
        _logger.e("$tag - getInfo: exception raised while trying to load the info from cache.", error: e);
      }
    }

    if (fromCacheOnly) {
      return _info;
    }

    try {
      final fetchedInfo = await _signetsApiClient.getStudentInfo();

      _logger.d("$tag - getInfo: $fetchedInfo info fetched.");

      if (_info != fetchedInfo) {
        _info = fetchedInfo;

        // Update cache
        _cacheManager.update(infoCacheKey, jsonEncode(_info));
      }
    } on CacheException catch (_) {
      _logger.e("$tag - getInfo: exception raised while trying to update the cache.");
      return _info!;
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, "Exception raised during getInfo: $e", e, stacktrace);
      rethrow;
    }

    return _info!;
  }
}
