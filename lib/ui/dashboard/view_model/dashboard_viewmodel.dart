// Flutter imports:
import 'package:flutter/material.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/logic/session_progress_use_case.dart';

class DashboardViewModel extends FutureViewModel {
  static const String tag = "DashboardViewModel";
  static const String abandonedGradeCode = "XX";


  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository = locator<BroadcastMessageRepository>();
  final SessionProgressUseCase _sessionProgressUseCase;

  StreamSubscription? _sessionProgressSubscription;

  /// Animation controller for the circle
  AnimationController? _controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Getter for the animation controller
  AnimationController get controller => _controller!;

  /// Localization class of the application.
  final AppIntl _appIntl;

  BroadcastMessage? broadcastMessage;
  SessionProgress? sessionProgress;
  DashboardViewModel({required AppIntl intl})
    : _appIntl = intl,
      _sessionProgressUseCase = SessionProgressUseCase(),
      /// if the animation has not been played, play it
      shouldPlayAnimation = !hasAnimationPlayed {
    hasAnimationPlayed = true;
  }

  static Future<bool> launchInAppReview() async {
    final PreferencesService preferencesService = locator<PreferencesService>();
    final InAppReviewService inAppReviewService = locator<InAppReviewService>();

    DateTime? ratingTimerFlagDate = await preferencesService.getDateTime(PreferencesFlag.ratingTimer);

    final hasRatingBeenRequested = await preferencesService.getBool(PreferencesFlag.hasRatingBeenRequested) ?? false;

    // If the user is already logged in while doing the update containing the In_App_Review PR.
    if (ratingTimerFlagDate == null) {
      final sevenDaysLater = DateTime.now().add(const Duration(days: 7));
      preferencesService.setDateTime(PreferencesFlag.ratingTimer, sevenDaysLater);
      ratingTimerFlagDate = sevenDaysLater;
    }

    if (await inAppReviewService.isAvailable() &&
        !hasRatingBeenRequested &&
        DateTime.now().isAfter(ratingTimerFlagDate)) {
      await Future.delayed(const Duration(seconds: 2), () async {
        await inAppReviewService.requestReview();
        preferencesService.setBool(PreferencesFlag.hasRatingBeenRequested, value: true);
      });

      return true;
    }
    return false;
  }

  /// Static flag to track if the animation has been played
  static bool hasAnimationPlayed = false;

  /// Tracks if the animation should be played
  final bool shouldPlayAnimation;


  /// Loading state of the widget
  bool isLoading = false;

  /// Slide offset for title and subtitle animations (slide from top)
  /// Vertical slide offset from 0.0 (x), -15.0 (y) to 0 (y)
  Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - titleAnimation.value));

  /// Fade-in opacity based on title animation progress
  double get titleFadeOpacity => titleAnimation.value;

  Future<void> init(TickerProvider ticker) async {
    initAnimationController(ticker);
    await initSessionProgress();
  }

  /// Initialize the animation controller for the circle
  void initAnimationController(TickerProvider ticker) {
    _controller = AnimationController(vsync: ticker, duration: const Duration(milliseconds: 1250));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 240,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.ease));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

    if (shouldPlayAnimation) {
      _controller!.forward();
    } else {
      _controller!.value = 1.0;
    }
  }

  Future<void> initSessionProgress() async {
    _sessionProgressSubscription = _sessionProgressUseCase.stream.listen(
      (sessionProgress) {
        this.sessionProgress = sessionProgress;
        notifyListeners();
      },
      onError: (error) {
        if (error is Exception) {
          _analyticsService.logError(tag, "SessionProgressWidget error", error);
        }
        if (error is String) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      },
    );
    await _sessionProgressUseCase.init();
  }
  
  static Future<void> launchBroadcastUrl(String url) async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    launchUrlService.launchInBrowser(url);
  }

  /// List of courses for the current session
  List<Course> courses = [];

  @override
  Future futureToRun() async {
    return Future.wait([
      futureToRunBroadcast(),
      futureToRunGrades(),
      _sessionProgressUseCase.fetch(forceUpdate: true),
    ]);
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Get the list of courses for the Grades card.
  Future<List<Course>> futureToRunGrades() async {
    if (!busy(courses)) {
      try {
        setBusyForObject(courses, true);
        if (_courseRepository.sessions == null || _courseRepository.sessions!.isEmpty) {
          await _courseRepository.getSessions();
        }

        // Determine current sessions
        if (_courseRepository.activeSessions.isEmpty) {
          return [];
        }
        final currentSession = _courseRepository.activeSessions.first;

        final coursesCached = await _courseRepository.getCourses(fromCacheOnly: true);
        courses.clear();
        for (final Course course in coursesCached) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
            courses.add(course);
          }
        }
        notifyListeners();

        final fetchedCourses = await _courseRepository.getCourses();
        // Update the courses list
        courses.clear();
        for (final Course course in fetchedCourses) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
            courses.add(course);
          }
        }
        // Will remove duplicated courses in the list
        courses = courses.toSet().toList();
      } catch (e) {
        onError(e, null);
      } finally {
        setBusyForObject(courses, false);
      }
    }
    return courses;
  }

  Future<void> futureToRunBroadcast() async {
    setBusyForObject(broadcastMessage, true);

    try {
      broadcastMessage = _broadcastMessageRepository.getBroadcastMessage(_appIntl.localeName);
    } catch (e) {
      onError(e, null);
    } finally {
      setBusyForObject(broadcastMessage, false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _sessionProgressSubscription?.cancel();
    _sessionProgressUseCase.dispose();
    super.dispose();
  }
}
