// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/session.dart';

// UTILS
import 'package:notredame/core/utils/cache_exception.dart';
import 'package:notredame/core/utils/api_exception.dart';

// OTHER
import 'package:notredame/locator.dart';

/// Repository to access all the data related to courses taken by the student
class CourseRepository {
  static const String tag = "CourseRepository";

  @visibleForTesting
  static const String coursesActivitiesCacheKey = "coursesActivitiesCache";

  @visibleForTesting
  static const String sessionsCacheKey = "sessionsCache";

  @visibleForTesting
  static const String coursesCacheKey = "coursesCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Principal access to the SignetsAPI
  final SignetsApi _signetsApi = locator<SignetsApi>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Student list of courses
  List<Course> _courses;

  List<Course> get courses => _courses;

  /// List of the courses activities for the student
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
  /// is updated with the latest version of the activities.
  Future<List<CourseActivity>> getCoursesActivities(
      {bool fromCacheOnly = false}) async {
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
        _logger.d(
            "$tag - getCoursesActivities: ${_coursesActivities.length} activities loaded from cache");
        if (fromCacheOnly) {
          return _coursesActivities;
        }
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getCoursesActivities: exception raised will trying to load activities from cache.");
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
        _logger.d(
            "$tag - getCoursesActivities: fetched ${fetchedCoursesActivities.length} activities.");
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
      _logger.e(
          "$tag - getCoursesActivities: exception raised will trying to update the cache.");
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
        _logger.d(
            "$tag - getSessions: ${_sessions.length} sessions loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getSessions: exception raised will trying to load the sessions from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await _userRepository.getPassword();

      final List<Session> fetchedSession = await _signetsApi.getSessions(
          username: _userRepository.monETSUser.universalCode,
          password: password);
      _logger
          .d("$tag - getSessions: ${fetchedSession.length} sessions fetched.");
      for (final Session session in fetchedSession) {
        if (!_sessions.contains(session)) {
          _sessions.add(session);
        }
      }

      // Update cache
      _cacheManager.update(sessionsCacheKey, jsonEncode(_sessions));
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getSessions: exception raised will trying to update the cache.");
      return _sessions;
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getSessions: $e");
      rethrow;
    }

    return _sessions;
  }

  /// Get the student's course list. After fetching the courses from [SignetsApi],
  /// the [CacheManager] is updated with the latest version of the courses.
  Future<List<Course>> getCourses({bool fromCacheOnly = false}) async {
    // Load the activities from the cache if the list doesn't exist
    if (_courses == null) {
      _courses = [];
      try {
        final List responseCache =
            jsonDecode(await _cacheManager.get(coursesCacheKey))
                as List<dynamic>;

        // Build list of activities loaded from the cache.
        _courses = responseCache
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d(
            "$tag - getCourses: ${_courses.length} courses loaded from cache");
        if (fromCacheOnly) {
          return _courses;
        }
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getCourses: exception raised will trying to load courses from cache.");
      }
    }

    final List<Course> fetchedCourses = [];

    try {
      final String password = await _userRepository.getPassword();
      fetchedCourses.addAll(await _signetsApi.getCourses(
          username: _userRepository.monETSUser.universalCode,
          password: password));
      _logger.d("$tag - getCourses: fetched ${fetchedCourses.length} courses.");

      for (int i = 0; i < fetchedCourses.length; i++) {
        // If there isn't the grade yet, will fetch the summary.
        // We don't do this for every course to avoid losing time.
        if (fetchedCourses[i].grade == null) {
          try {
            await getCourseSummary(fetchedCourses[i]);
            fetchedCourses.remove(fetchedCourses[i]);
          } on ApiException catch (_) {
            _logger.e(
                "$tag - getCourses: Exception raised while trying to get summary "
                    "of ${fetchedCourses[i].acronym}.");
          }
        }
      }
    } on Exception catch (e) {
      _analyticsService.logError(tag, "Exception raised during getCourses: $e");
      _logger.e("$tag - getCourses: Exception raised $e");
      rethrow;
    }

    // Update the list of courses
    for (final Course course in fetchedCourses) {
      final index =
          _courses.indexWhere((element) => element.acronym == course.acronym);
      if (index != -1 && _courses[index] != course) {
        _courses.removeAt(index);
        _courses.insert(index, course);
      } else {
        _courses.add(course);
      }
    }

    try {
      // Update cache
      _cacheManager.update(coursesCacheKey, jsonEncode(_courses));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getCourses: exception raised will trying to update the cache.");
    }

    return _courses;
  }

  /// Get the summary (detailed evaluations) of [course]. After fetching the
  /// summary from [SignetsApi], the [CacheManager] is updated with the latest
  /// version of the course. Return the course with the summary set.
  Future<Course> getCourseSummary(Course course) async {
    CourseSummary summary;
    try {
      final String password = await _userRepository.getPassword();
      summary = await _signetsApi.getCourseSummary(
          username: _userRepository.monETSUser.universalCode,
          password: password,
          course: course);
      _logger.d("$tag - getCourseSummary: fetched ${course.acronym} summary.");
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getCourseSummary: $e");
      _logger.e("$tag - getCourseSummary: Exception raised $e");
      rethrow;
    }

    // Initialize the array
    _courses ??= [];

    // Update courses list
    course.summary = summary;
    _courses.add(course);

    try {
      // Update cache
      _cacheManager.update(coursesCacheKey, jsonEncode(_courses));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and
      // the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getCourseSummary: exception raised will trying to update the cache.");
    }

    return course;
  }
}
