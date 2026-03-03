// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/session_reminder_helper.dart';
import '../../../data/services/in_app_review_service.dart';
import '../../../data/services/preferences_service.dart';
import '../../../domain/constants/preferences_flags.dart';

class DashboardViewModel extends FutureViewModel {
  static const String tag = "DashboardViewModel";
  static const String abandonedGradeCode = "XX";

  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository = locator<BroadcastMessageRepository>();

  /// Animation controller for the circle
  AnimationController? _controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Getter for the animation controller
  AnimationController get controller => _controller!;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  BroadcastMessage? broadcastMessage;

  /// Next upcoming session reminder event
  SessionReminder? sessionReminder;

  /// All upcoming session reminders
  List<SessionReminder> allSessionReminders = [];

  /// Reminders sharing the same date as the active reminder (for carousel)
  List<SessionReminder> sameDayReminders = [];

  /// Get progress of the session
  double get progress => _progress;

  List<int> get sessionDays => _sessionDays;

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

  /// Return session progress based on today's [date]
  double getSessionProgress() {
    if (_courseRepository.activeSessions.isEmpty) {
      return -1.0;
    } else {
      return sessionDays[0] / sessionDays[1];
    }
  }

  /// Static flag to track if the animation has been played
  static bool hasAnimationPlayed = false;

  /// Tracks if the animation should be played
  final bool shouldPlayAnimation;

  DashboardViewModel({required AppIntl intl})
    : _appIntl = intl,

      /// if the animation has not been played, play it
      shouldPlayAnimation = !hasAnimationPlayed {
    hasAnimationPlayed = true;
  }

  /// Loading state of the widget
  bool isLoading = false;

  /// Slide offset for title and subtitle animations (slide from top)
  /// Vertical slide offset from 0.0 (x), -15.0 (y) to 0 (y)
  Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - titleAnimation.value));

  /// Fade-in opacity based on title animation progress
  double get titleFadeOpacity => titleAnimation.value;

  /// Initialize the animation controller for the circle
  void init(TickerProvider ticker) {
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

  @override
  void dispose() {
    // Dispose the controller only if it has been initialized and its not null
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  static Future<void> launchBroadcastUrl(String url) async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    launchUrlService.launchInBrowser(url);
  }

  /// Returns a list containing the number of elapsed days in the active session
  /// and the total number of days in the session
  List<int> getSessionDays() {
    if (_courseRepository.activeSessions.isEmpty) {
      return [0, 0];
    } else {
      int dayCompleted = _settingsManager.dateTimeNow
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays;
      final dayInTheSession = _courseRepository.activeSessions.first.endDate
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays;

      if (dayCompleted > dayInTheSession) {
        dayCompleted = dayInTheSession;
      } else if (dayCompleted < 0) {
        dayCompleted = 0;
      }

      return [dayCompleted, dayInTheSession];
    }
  }

  /// List of courses for the current session
  List<Course> courses = [];

  @override
  Future futureToRun() async {
    await loadDataAndUpdateWidget();
  }

  Future loadDataAndUpdateWidget() async {
    return Future.wait([futureToRunBroadcast(), futureToRunGrades(), futureToRunSessionProgressBar()]);
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    try {
      setBusyForObject(progress, true);
      final sessions = await _courseRepository.getSessions();
      _sessionDays = getSessionDays();
      _progress = getSessionProgress();
      if (_courseRepository.activeSessions.isNotEmpty) {
        final s = _courseRepository.activeSessions.first;
        final now = DateTime(2026, 1, 27); // TODO: revert to _settingsManager.dateTimeNow
        // TODO: remove — testing override to force all reminders on Jan 31
        final testSession = Session(
          shortName: s.shortName,
          name: s.name,
          startDate: DateTime(2026, 1, 31),
          endDate: s.endDate,
          endDateCourses: s.endDateCourses,
          startDateRegistration: DateTime(2026, 1, 31),
          deadlineRegistration: DateTime(2026, 1, 31),
          startDateCancellationWithRefund: DateTime(2026, 1, 31),
          deadlineCancellationWithRefund: DateTime(2026, 1, 2),
          deadlineCancellationWithRefundNewStudent: DateTime(2026, 1, 2),
          startDateCancellationWithoutRefundNewStudent: DateTime(2026, 1, 2),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2026, 1, 2),
          deadlineCancellationASEQ: DateTime(2026, 1, 31),
        );
        sessionReminder = SessionReminderHelper.getActiveReminder(testSession, now);
        allSessionReminders = SessionReminderHelper.getAllUpcomingReminders(testSession, now);
        sameDayReminders = SessionReminderHelper.getSameDayReminders(testSession, now);
      } else {
        sessionReminder = null;
        allSessionReminders = [];
        sameDayReminders = [];
      }
      return sessions;
    } catch (e) {
      onError(e, null);
    } finally {
      setBusyForObject(progress, false);
    }
    return [];
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

  String getProgressBarText(BuildContext context) {
    return (sessionDays[1] - sessionDays[0]).toString();
  }
}
