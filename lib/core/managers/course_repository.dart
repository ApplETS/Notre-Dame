// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/session.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/signets_api.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// UTILS
import 'package:notredame/core/utils/cache_exception.dart';

// OTHER
import 'package:notredame/locator.dart';

/// Repository to access all the data related to courses taken by the student
class CourseRepository {
  static const String tag = "CourseRepository";

  @visibleForTesting
  static const String coursesActivitiesCacheKey = "coursesActivitiesCache";

  @visibleForTesting
  static const String sessionsCacheKey = "sessionsCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Principal access to the SignetsAPI
  final SignetsApi _signetsApi = locator<SignetsApi>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// List of the courses session for the student
  List<CourseActivity> _coursesActivities;

  List<CourseActivity> get coursesActivities => _coursesActivities;

  /// List of session where the student has been registered.
  /// The sessions are organized from oldest to youngest
  List<Session> _sessions;

  List<Session> get sessions => _sessions;

  /// Return the active sessions which mean the sessions that the endDate isn't already passed.
  @visibleForTesting
  List<Session> get activeSessions {
    final DateTime now = DateTime.now();

    return _sessions
        ?.where((session) => session.endDate.isAfter(now))
        ?.toList();
  }

  /// Get and update the list of courses activities for the active sessions.
  /// After fetching the new activities from the [SignetsApi] the [CacheManager]
  /// is updated wish the latest version of the activities.
  Future<List<CourseActivity>> getCoursesActivities() async {
    // Load the activities from the cache if the list doesn't exist
    if (_coursesActivities == null) {
      _coursesActivities = [];
      try {
        final List responseCache =
            jsonDecode(await _cacheManager.get(coursesActivitiesCacheKey))
                as List<dynamic>;

        // Build list of activities loaded from the cache.
        _coursesActivities = responseCache
            .map((e) => CourseActivity.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d("$tag - getCoursesActivities: ${_coursesActivities.length} activities loaded from cache");
      } on CacheException catch (_) {
        _logger.e("$tag - getCoursesActivities: exception raised will trying to load activities from cache.");
      }
    }

    final List<CourseActivity> fetchedCoursesActivities = [];

    try {
      // If there is no sessions loaded, load them.
      if (_sessions == null) {
        await getSessions();
      }

      final String password = await _userRepository.getPassword();
      for (final Session session in activeSessions) {
        fetchedCoursesActivities.addAll(await _signetsApi.getCoursesActivities(
            username: _userRepository.monETSUser.universalCode,
            password: password,
            session: session.shortName));
        _logger.d("$tag - getCoursesActivities: fetched ${fetchedCoursesActivities.length} activities.");
      }
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getCoursesActivities: $e");
      _logger.d("$tag - getCoursesActivities: Exception raised $e");
      rethrow;
    }

    // Update the list of activities to avoid duplicate activities
    for (final CourseActivity activity in fetchedCoursesActivities) {
      if (!_coursesActivities.contains(activity)) {
        _coursesActivities.add(activity);
      }
    }

    try {
      // Update cache
      _cacheManager.update(
          coursesActivitiesCacheKey, jsonEncode(_coursesActivities));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e("$tag - getCoursesActivities: exception raised will trying to update the cache.");
    }

    return _coursesActivities;
  }

  /// Get the list of session on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<List<Session>> getSessions() async {
    // Load the sessions from the cache if the list doesn't exist
    if (_sessions == null) {
      try {
        _sessions = [];
        final String res = await _cacheManager.get(sessionsCacheKey);
        final List sessionsCached = jsonDecode(res) as List<dynamic>;

        // Build list of activities loaded from the cache.
        _sessions = sessionsCached
            .map((e) => Session.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d("$tag - getSessions: ${_sessions.length} sessions loaded from cache.");
      } on CacheException catch (_) {
        _logger.e("$tag - getSessions: exception raised will trying to load the sessions from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await _userRepository.getPassword();

      final List<Session> fetchedSession = await _signetsApi.getSessions(
          username: _userRepository.monETSUser.universalCode,
          password: password);
      _logger.d("$tag - getSessions: ${fetchedSession.length} sessions fetched.");
      for (final Session session in fetchedSession) {
        if (!_sessions.contains(session)) {
          _sessions.add(session);
        }
      }

      // Update cache
      _cacheManager.update(sessionsCacheKey, jsonEncode(_sessions));
    } on CacheException catch (_) {
      _logger.e("$tag - getSessions: exception raised will trying to update the cache.");
      return _sessions;
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getSessions: $e");
      rethrow;
    }

    return _sessions;
  }
}
