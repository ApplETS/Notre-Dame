// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/signets_api.dart';

// UTILS
import 'package:notredame/core/utils/cache_exception.dart';

// OTHER
import 'package:notredame/locator.dart';

/// Repository to access all the data related to courses taken by the student
class ProfileRepository {
  static const String tag = "ProfileRepository";

  @visibleForTesting
  static const String infoCacheKey = "infoCache";

  @visibleForTesting
  static const String programsCacheKey = "programsCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Principal access to the SignetsAPI
  final SignetsApi _signetsApi = locator<SignetsApi>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// List of session where the student has been registered.
  /// The sessions are organized from oldest to youngest
  List<ProfileStudent> _info;

  ProfileStudent get info =>
      _info == null || _info.isEmpty ? null : _info.first;

  List<Program> _programs;

  List<Program> get programs => _programs;

  /// Get the list of session on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<ProfileStudent> getInfos() async {
    // Load the sessions from the cache if the list doesn't exist
    if (_info == null) {
      try {
        _info = [];
        final String res = await _cacheManager.get(infoCacheKey);
        final List infoCached = jsonDecode(res) as List<dynamic>;

        // Build list of activities loaded from the cache.
        _info = infoCached
            .map((e) => ProfileStudent.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d("$tag - getInfo: ${_info.length} info loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getInfo: exception raised will trying to load the info from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await _userRepository.getPassword();

      final ProfileStudent fetchedInfo = await _signetsApi.getStudentInfo(
          username: _userRepository.monETSUser.universalCode,
          password: password);
      _logger.d("$tag - getInfo: $fetchedInfo info fetched.");

      if (!_info.contains(fetchedInfo)) {
        _info.add(fetchedInfo);
      }

      // Update cache
      _cacheManager.update(infoCacheKey, jsonEncode(_info));
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getInfo: exception raised will trying to update the cache.");
      return _info.first;
    } on Exception catch (e) {
      _analyticsService.logError(tag, "Exception raised during getInfo: $e");
      rethrow;
    }
    return _info.first;
  }

  /// Get the list of session on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<List<Program>> getPrograms() async {
    // Load the sessions from the cache if the list doesn't exist
    if (_programs == null) {
      try {
        _programs = [];
        final String res = await _cacheManager.get(programsCacheKey);
        final List sessionsCached = jsonDecode(res) as List<dynamic>;

        // Build list of activities loaded from the cache.
        _programs = sessionsCached
            .map((e) => Program.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d(
            "$tag - getSessions: ${_programs.length} sessions loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getSessions: exception raised will trying to load the sessions from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await _userRepository.getPassword();

      final List<Program> fetchedSession = await _signetsApi.getPrograms(
          username: _userRepository.monETSUser.universalCode,
          password: password);
      _logger
          .d("$tag - getSessions: ${fetchedSession.length} sessions fetched.");
      for (final Program session in fetchedSession) {
        if (!_programs.contains(session)) {
          _programs.add(session);
        }
      }

      // Update cache
      _cacheManager.update(programsCacheKey, jsonEncode(_programs));
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getSessions: exception raised will trying to update the cache.");
      return _programs;
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getSessions: $e");
      rethrow;
    }

    return _programs;
  }
}
