// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/progress_bar_text_options.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";
  static const String abandonedGradeCode = "XX";

  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository = locator<BroadcastMessageRepository>();

  /// Animation controller for the circle
  AnimationController? _controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Getter for the animation controller
  AnimationController get controller => _controller!;

  /// Check if the controller is initialized
  bool get _isControllerInitialized => _controller != null;

  /// All dashboard displayable cards
  Map<PreferencesFlag, int>? _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Cards to display on dashboard
  List<PreferencesFlag>? _cardsToDisplay;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  BroadcastMessage? broadcastMessage;

  /// Get progress of the session
  double get progress => _progress;

  List<int> get sessionDays => _sessionDays;

  /// Activities for today
  final List<CourseActivity> _scheduleEvents = [];

  /// Get the list of activities for today
  List<CourseActivity> get scheduleEvents {
    return _scheduleEvents;
  }

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int>? get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag>? get cardsToDisplay => _cardsToDisplay;

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

  /// TODO : add AppIntl to the messages
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
      end: 330,
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
    if (_isControllerInitialized) {
      _controller!.dispose();
    }
    super.dispose();
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
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    _cards = await _settingsManager.getDashboard();

    getCardsToDisplay();

    await loadDataAndUpdateWidget();

    return _cards!;
  }

  Future loadDataAndUpdateWidget() async {
    return Future.wait([
      futureToRunBroadcast(),
      futureToRunGrades(),
      futureToRunSessionProgressBar(),
      futureToRunSchedule(),
    ]);
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Change the order of [flag] card from [oldIndex] to [newIndex].
  void setOrder(PreferencesFlag flag, int newIndex) {
    _cardsToDisplay?.remove(flag);
    _cardsToDisplay?.insert(newIndex, flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Reordoring ${flag.name}");
  }

  /// Hide [flag] card from dashboard by setting int value -1
  void hideCard(PreferencesFlag flag) {
    _cards?.update(flag, (value) => -1);

    _cardsToDisplay?.remove(flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Deleting ${flag.name}");
  }

  /// Reset all card indexes to their default values
  void setAllCardsVisible() {
    _cards?.updateAll((key, value) {
      _settingsManager.setInt(key, key.index - PreferencesFlag.aboutUsCard.index).then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
      return key.index - PreferencesFlag.aboutUsCard.index;
    });

    getCardsToDisplay();

    loadDataAndUpdateWidget();

    notifyListeners();
  }

  /// Populate list of cards used in view
  void getCardsToDisplay() {
    _cardsToDisplay = [];

    if (_cards != null) {
      final orderedCards = SplayTreeMap<PreferencesFlag, int>.from(
        _cards!,
        (a, b) => _cards![a]!.compareTo(_cards![b]!),
      );

      orderedCards.forEach((key, value) {
        if (value >= 0) {
          _cardsToDisplay?.insert(value, key);
        }
      });
    }

    _analyticsService.logEvent(tag, "Restoring cards");
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    try {
      setBusyForObject(progress, true);
      final sessions = await _courseRepository.getSessions();
      _sessionDays = getSessionDays();
      _progress = getSessionProgress();
      return sessions;
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(progress, false);
    }
    return [];
  }

  Future<List<CourseActivity>> futureToRunSchedule() async {
    try {
      setBusyForObject(scheduleEvents, true);
      scheduleEvents.clear();
      await _courseRepository.getCoursesActivities();

      final now = _settingsManager.dateTimeNow;
      final tomorrow = now.add(const Duration(days: 1)).withoutTime;
      final twoDaysFromNow = now.add(const Duration(days: 2)).withoutTime;

      final courseActivities =
          _courseRepository.coursesActivities
              ?.where((activity) => activity.endDateTime.isAfter(now) && activity.endDateTime.isBefore(twoDaysFromNow))
              .sorted((a, b) => a.startDateTime.compareTo(b.startDateTime))
              .toList() ??
          [];

      for (final activity in courseActivities) {
        final isToday = now.compareWithoutTime(activity.startDateTime);
        final isTomorrow = activity.startDateTime.withoutTime == tomorrow;

        if ((isToday || isTomorrow) && await _isLaboratoryGroupToAdd(activity)) {
          if (isTomorrow && scheduleEvents.isNotEmpty && scheduleEvents.first.startDateTime.compareWithoutTime(now)) {
            return scheduleEvents;
          }
          scheduleEvents.add(activity);
        }
      }
      return scheduleEvents;
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(scheduleEvents, false);
    }
    return [];
  }

  Future<bool> _isLaboratoryGroupToAdd(CourseActivity courseActivity) async {
    final courseKey = courseActivity.courseGroup.split('-').first;

    final activityCodeToUse = await _settingsManager.getDynamicString(
      PreferencesFlag.scheduleLaboratoryGroup,
      courseKey,
    );

    return activityCodeToUse == ActivityCode.labGroupA
        ? courseActivity.activityDescription != ActivityDescriptionName.labB
        : activityCodeToUse == ActivityCode.labGroupB
        ? courseActivity.activityDescription != ActivityDescriptionName.labA
        : true;
  }

  /// Update cards order and display status in preferences
  void updatePreferences() {
    if (_cards == null || _cardsToDisplay == null) {
      return;
    }
    for (final MapEntry<PreferencesFlag, int> element in _cards!.entries) {
      _cards![element.key] = _cardsToDisplay!.indexOf(element.key);
      _settingsManager.setInt(element.key, _cardsToDisplay!.indexOf(element.key)).then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
    }
  }

  /// Returns true if dates [a] and [b] are on the same day
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

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
      } catch (error) {
        onError(error);
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
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(broadcastMessage, false);
    }
  }

  void onCardReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // ignore: parameter_assignments
      newIndex -= 1;
    }

    // Should not happen becase dismiss card will not be called if the card is null.
    if (cards == null) {
      _analyticsService.logError("DashboardView", "Cards list is null");
      throw Exception("Cards is null");
    }

    final PreferencesFlag elementMoved = cards!.keys.firstWhere((element) => cards![element] == oldIndex);

    setOrder(elementMoved, newIndex);
  }

  String getProgressBarText(BuildContext context) {
    return (sessionDays[1] - sessionDays[0]).toString();
  }
}
