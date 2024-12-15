// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/models/signets_errors.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/domain/constants/semester_codes.dart';
import 'package:notredame/utils/api_exception.dart';
import 'package:notredame/utils/cache_exception.dart';
import 'package:notredame/locator.dart';

/// Repository to access all the data related to courses taken by the student
class CourseRepository {
  static const String tag = "CourseRepository";

  @visibleForTesting
  static const String coursesActivitiesCacheKey = "coursesActivitiesCache";

  @visibleForTesting
  static const String scheduleActivitiesCacheKey = "scheduleActivitiesCache";

  @visibleForTesting
  static const String scheduleDefaultActivitiesCacheKey =
      "scheduleDefaultActivitiesCache";

  @visibleForTesting
  static const String sessionsCacheKey = "sessionsCache";

  @visibleForTesting
  static const String coursesCacheKey = "coursesCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// To access the user currently logged
  final UserRepository _userRepository = locator<UserRepository>();

  /// Cache manager to access and update the cache.
  final CacheService _cacheManager = locator<CacheService>();

  /// Used to verify if the user has connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Used to access the Signets API
  final SignetsAPIClient _signetsApiClient = locator<SignetsAPIClient>();

  /// Student list of courses
  List<Course>? _courses;

  List<Course>? get courses => _courses;

  /// List of the courses activities for the student
  List<CourseActivity>? _coursesActivities;

  List<CourseActivity>? get coursesActivities => _coursesActivities;

  /// List of the schedule activities for the student in the active session
  List<ScheduleActivity>? _scheduleActivities;

  List<ScheduleActivity>? get scheduleActivities => _scheduleActivities;

  /// List of the default schedule activities for the student
  late List<ScheduleActivity> _scheduleDefaultActivities;

  List<ScheduleActivity>? get scheduleDefaultActivities => _scheduleActivities;

  /// List of session where the student has been registered.
  /// The sessions are organized from oldest to youngest
  List<Session>? _sessions;

  List<Session>? get sessions => _sessions;

  /// Return the active sessions which mean the sessions that the endDate isn't already passed.
  List<Session> get activeSessions {
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    return _sessions
            ?.where((session) =>
                session.endDate.isAfter(now) ||
                session.endDate.isAtSameMomentAs(now))
            .toList() ??
        [];
  }

  /// Get and update the list of courses activities for the active sessions.
  /// After fetching the new activities from the [SignetsApi] the [CacheService]
  /// is updated with the latest version of the activities.
  Future<List<CourseActivity>?> getCoursesActivities(
      {bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

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
            "$tag - getCoursesActivities: ${_coursesActivities?.length ?? 0} activities loaded from cache");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getCoursesActivities: exception raised while trying to load activities from cache.");
      }
    }

    if (fromCacheOnly) {
      return _coursesActivities;
    }

    final List<CourseActivity> fetchedCoursesActivities = [];

    try {
      // If there is no sessions loaded, load them.
      if (_sessions == null || _sessions!.isEmpty) {
        await getSessions();
      }

      if (_userRepository.monETSUser != null) {
        final String password = await _userRepository.getPassword();
        for (final Session session in activeSessions) {
          fetchedCoursesActivities.addAll(
              await _signetsApiClient.getCoursesActivities(
                  username: _userRepository.monETSUser!.universalCode,
                  password: password,
                  session: session.shortName));
          _logger.d(
              "$tag - getCoursesActivities: fetched ${fetchedCoursesActivities.length} activities.");
        }
      }
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag,
          "Exception raised during getCoursesActivities: $e", e, stacktrace);
      _logger.d("$tag - getCoursesActivities: Exception raised $e");
      rethrow;
    }

    // Remove all the activities that are in the actives sessions.
    DateTime activeSessionStartDate = DateTime.now();
    for (final element in activeSessions) {
      if (element.startDate.isBefore(activeSessionStartDate)) {
        activeSessionStartDate = element.startDate;
      }
    }
    _coursesActivities?.removeWhere(
        (element) => element.startDateTime.isAfter(activeSessionStartDate));

    // Update the list of activities to avoid duplicate activities
    for (final CourseActivity activity in fetchedCoursesActivities) {
      if (_coursesActivities != null &&
          !_coursesActivities!.contains(activity)) {
        _coursesActivities!.add(activity);
      }
    }

    try {
      // Update cache
      _cacheManager.update(
          coursesActivitiesCacheKey, jsonEncode(_coursesActivities));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getCoursesActivities: exception raised while trying to update the cache.");
    }

    return _coursesActivities;
  }

  /// Get and update the list of schedule activities for the active sessions.
  /// After fetching the new activities from the [SignetsApi] the [CacheService]
  /// is updated with the latest version of the schedule activities.
  Future<List<ScheduleActivity>> getDefaultScheduleActivities({
    String? session,
    bool fromCacheOnly = false,
  }) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

    if (session == null || session == SemesterCodes.noActiveSemester) {
      _logger.d(
          "$tag - getScheduleDefaultActivities: Session is null, returning empty list.");
      return [];
    }

    // Load the activities from the cache if the list doesn't exist or if another session is provided
    _scheduleDefaultActivities = [];
    try {
      final List responseCache = jsonDecode(await _cacheManager
          .get(scheduleDefaultActivitiesCacheKey + session)) as List<dynamic>;

      // Build list of activities loaded from the cache.
      _scheduleDefaultActivities = responseCache
          .map((e) => ScheduleActivity.fromJson(e as Map<String, dynamic>))
          .toList();
      _logger.d(
          "$tag - getScheduleDefaultActivities: ${_scheduleDefaultActivities.length} activities loaded from cache");
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getDefaultScheduleActivities: exception raised while trying to load activities from cache.");
    }

    if (fromCacheOnly) {
      return _scheduleDefaultActivities;
    }
    final List<ScheduleActivity> fetchedScheduleActivities = [];

    try {
      final String password = await _userRepository.getPassword();

      fetchedScheduleActivities.addAll(
          await _signetsApiClient.getScheduleActivities(
              username: _userRepository.monETSUser?.universalCode ?? '',
              password: password,
              session: session));
      _logger.d(
          "$tag - getDefaultScheduleActivities: fetched ${fetchedScheduleActivities.length} default activities.");
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag,
          "Exception raised during getScheduleActivities: $e", e, stacktrace);
      _logger.d("$tag - getScheduleActivities: Exception raised $e");
      rethrow;
    }

    _scheduleDefaultActivities = fetchedScheduleActivities;

    try {
      // Update cache
      _cacheManager.update(scheduleDefaultActivitiesCacheKey + session,
          jsonEncode(_scheduleDefaultActivities));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getScheduleActivities: exception raised while trying to update the cache.");
    }

    return _scheduleDefaultActivities;
  }

  /// Get and update the list of schedule activities for the active sessions.
  /// After fetching the new activities from the [SignetsApi] the [CacheService]
  /// is updated with the latest version of the schedule activities.
  Future<List<ScheduleActivity>> getScheduleActivities(
      {bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

    // Load the activities from the cache if the list doesn't exist or if another session is provided
    if (_scheduleActivities == null) {
      _scheduleActivities = [];
      try {
        final List responseCache =
            jsonDecode(await _cacheManager.get(scheduleActivitiesCacheKey))
                as List<dynamic>;

        // Build list of activities loaded from the cache.
        _scheduleActivities = responseCache
            .map((e) => ScheduleActivity.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d(
            "$tag - getScheduleActivities: ${_scheduleActivities!.length} activities loaded from cache");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getScheduleActivities: exception raised while trying to load activities from cache.");
      }
    }

    if (fromCacheOnly) {
      return _scheduleActivities!;
    }

    final List<ScheduleActivity> fetchedScheduleActivities = [];

    try {
      // If there is no sessions loaded, load them.
      if (_sessions == null) {
        await getSessions();
      }

      if (_userRepository.monETSUser != null) {
        final String password = await _userRepository.getPassword();

        for (final Session oneSession in activeSessions) {
          fetchedScheduleActivities.addAll(
              await _signetsApiClient.getScheduleActivities(
                  username: _userRepository.monETSUser?.universalCode ?? '',
                  password: password,
                  session: oneSession.shortName));
          _logger.d(
              "$tag - getScheduleActivities: fetched ${fetchedScheduleActivities.length} activities.");
        }
      }
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag,
          "Exception raised during getScheduleActivities: $e", e, stacktrace);
      _logger.d("$tag - getScheduleActivities: Exception raised $e");
      rethrow;
    }

    // Update the list of activities to avoid duplicate activities
    for (final ScheduleActivity activity in fetchedScheduleActivities) {
      if (_scheduleActivities != null &&
          !_scheduleActivities!.contains(activity)) {
        _scheduleActivities!.add(activity);
      }
    }

    try {
      // Update cache
      _cacheManager.update(
          scheduleActivitiesCacheKey, jsonEncode(_scheduleActivities));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getScheduleActivities: exception raised while trying to update the cache.");
    }

    return _scheduleActivities!;
  }

  /// Get the list of session on which the student was active.
  /// The list from the [CacheService] is loaded than updated with the results
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
            "$tag - getSessions: ${_sessions?.length ?? 0} sessions loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getSessions: exception raised while trying to load the sessions from cache.");
      }
    }

    // Don't try to update cache when offline
    if (!(await _networkingService.hasConnectivity())) {
      return _sessions!;
    }

    try {
      if (_userRepository.monETSUser != null) {
        // getPassword will try to authenticate the user if not authenticated.
        final String password = await _userRepository.getPassword();

        final List<Session> fetchedSession =
            await _signetsApiClient.getSessions(
                username: _userRepository.monETSUser!.universalCode,
                password: password);
        _logger.d(
            "$tag - getSessions: ${fetchedSession.length} sessions fetched.");
        for (final Session session in fetchedSession) {
          if (!_sessions!.contains(session)) {
            _sessions!.add(session);
          }
        }

        // Update cache
        _cacheManager.update(sessionsCacheKey, jsonEncode(_sessions));
      }
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getSessions: exception raised while trying to update the cache.");
      return _sessions!;
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(
          tag, "Exception raised during getSessions: $e", e, stacktrace);
      rethrow;
    }

    return _sessions!;
  }

  /// Get the student's course list. After fetching the courses from [SignetsApi],
  /// the [CacheService] is updated with the latest version of the courses.
  Future<List<Course>> getCourses({bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

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
            "$tag - getCourses: ${_courses!.length} courses loaded from cache");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getCourses: exception raised while trying to load courses from cache.");
      }
    }

    if (fromCacheOnly) {
      return _courses!;
    }

    final List<Course> fetchedCourses = [];
    final Map<String, List<CourseReview>> fetchedCourseReviews = {};

    try {
      if (_userRepository.monETSUser != null) {
        final String password = await _userRepository.getPassword();

        fetchedCourses.addAll(await _signetsApiClient.getCourses(
            username: _userRepository.monETSUser!.universalCode,
            password: password));
        _logger
            .d("$tag - getCourses: fetched ${fetchedCourses.length} courses.");
      }
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(
          tag, "Exception raised during getCourses: $e", e, stacktrace);
      _logger.e("$tag - getCourses: Exception raised $e");
      rethrow;
    }

    try {
      fetchedCourseReviews.addAll(await _getCoursesReviews());
    } on Exception catch (e) {
      _logger.d("$tag - getCourses: $e during getCoursesEvaluations. Ignored");
    }

    _courses!.clear();

    // If there isn't the grade yet, will fetch the summary.
    // We don't do this for every course to avoid losing time.
    for (final course in fetchedCourses) {
      course.reviews = _getReviewsForCourse(course, fetchedCourseReviews);
      if (course.grade == null) {
        try {
          await getCourseSummary(course);
        } on ApiException catch (_) {
          _logger.e(
              "$tag - getCourses: Exception raised while trying to get summary "
              "of ${course.acronym}.");
          _courses!.add(course);
        }
      } else {
        _courses!.add(course);
      }
    }

    try {
      // Update cache
      _cacheManager.update(coursesCacheKey, jsonEncode(_courses));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getCourses: exception raised while trying to update the cache.");
    }

    return _courses!;
  }

  /// Get the summary (detailed evaluations) of [course]. After fetching the
  /// summary from [SignetsApi], the [CacheService] is updated with the latest
  /// version of the course. Return the course with the summary set.
  Future<Course> getCourseSummary(Course course) async {
    CourseSummary? summary;

    // Don't try to update the summary when user has no connection
    if (!(await _networkingService.hasConnectivity())) {
      return course;
    }

    try {
      if (_userRepository.monETSUser != null) {
        final String password = await _userRepository.getPassword();

        summary = await _signetsApiClient.getCourseSummary(
            username: _userRepository.monETSUser!.universalCode,
            password: password,
            course: course);
        _logger
            .d("$tag - getCourseSummary: fetched ${course.acronym} summary.");
      }
    } on Exception catch (e, stacktrace) {
      if (e is ApiException) {
        if (e.errorCode == SignetsError.gradesEmpty ||
            e.message.startsWith(SignetsError.gradesNotAvailable)) {
          _logger.e(
              "$tag - getCourseSummary: Summary is empty for ${course.acronym}.");
          rethrow;
        }
      }
      _analyticsService.logError(tag, e.toString(), e, stacktrace);
      _logger.e("$tag - getCourseSummary: Exception raised $e");
      rethrow;
    }

    // Initialize the array if needed
    _courses ??= [];

    // Update courses list
    _courses!.removeWhere((element) =>
        course.acronym == element.acronym && course.session == element.session);
    course.summary = summary;
    _courses!.add(course);

    try {
      // Update cache
      _cacheManager.update(coursesCacheKey, jsonEncode(_courses));
    } on CacheException catch (_) {
      // Do nothing, the caching will retry later and
      // the error has been logged by the [CacheManager]
      _logger.e(
          "$tag - getCourseSummary: exception raised while trying to update the cache.");
    }

    return course;
  }

  /// Retrieve the evaluation filtered by sessions.
  Future<Map<String, List<CourseReview>>> _getCoursesReviews() async {
    final Map<String, List<CourseReview>> reviews = {};
    List<CourseReview> sessionReviews = [];

    try {
      final String password = await _userRepository.getPassword();

      // If there is no sessions loaded, load them.
      if (_sessions == null) {
        await getSessions();
      }

      if (_userRepository.monETSUser != null) {
        for (final Session session in _sessions!) {
          sessionReviews = await _signetsApiClient.getCourseReviews(
              username: _userRepository.monETSUser!.universalCode,
              password: password,
              session: session);
          reviews.putIfAbsent(session.shortName, () => sessionReviews);
          _logger.d(
              "$tag - getCoursesEvaluations: fetched ${reviews[session.shortName]?.length ?? 0} "
              "evaluations for session ${session.shortName}.");
        }
      }
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(tag, e.toString(), e, stacktrace);
      _logger.e("$tag - getCourseSummary: Exception raised $e");
      rethrow;
    }

    return reviews;
  }

  /// Get the evaluation for a course or null if not found.
  List<CourseReview>? _getReviewsForCourse(
      Course course, Map<String, List<CourseReview>> reviews) {
    final reviewsList = reviews[course.session]
        ?.where((element) =>
            element.acronym == course.acronym && element.group == course.group)
        .toList();

    return reviewsList == null || reviewsList.isEmpty ? null : reviewsList;
  }
}
