// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/models/dynamic_message.dart';
import 'package:notredame/data/models/dynamic_message_context.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/dynamic_messages_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/cards/progress_bar_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/view_model/cards/grades_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/view_model/cards/schedule_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/view_model/cards/session_reminder_card_viewmodel.dart';

class DashboardViewModel extends FutureViewModel {
  static const String tag = "DashboardViewModel";

  final CourseRepository _courseRepository = locator<CourseRepository>();
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository = locator<BroadcastMessageRepository>();
  final DynamicMessagesService _dynamicMessagesService = locator<DynamicMessagesService>();
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Animation controller for the circle
  AnimationController? _controller;

  /// Getter for the animation controller
  AnimationController get controller => _controller!;

  /// Localization class of the application.
  final AppIntl _appIntl;

  BroadcastMessage? broadcastMessage;
  SessionProgress? sessionProgress;

  /// Dynamic message text resolved from SessionContext
  String? dynamicMessageText;

  /// if the progress bar is displaying the days remaining or another alternative
  bool get showingPercentage => progressBarModel.showingPercentage;

  late final ProgressBarCardViewmodel progressBarModel;
  late final GradesCardViewmodel gradesModel;
  late final ScheduleCardViewmodel scheduleModel;
  late final SessionReminderCardViewmodel sessionReminderModel;

  DashboardViewModel({required AppIntl intl}) : _appIntl = intl {
    progressBarModel = ProgressBarCardViewmodel(intl: intl);
    progressBarModel.addListener(notifyListeners);

    gradesModel = GradesCardViewmodel(intl: intl);
    gradesModel.addListener(notifyListeners);

    scheduleModel = ScheduleCardViewmodel(intl: intl);
    scheduleModel.addListener(notifyListeners);

    sessionReminderModel = SessionReminderCardViewmodel(intl: intl);
    sessionReminderModel.addListener(notifyListeners);
  }

  static Future<bool> launchInAppReview() async {
    final SettingsRepository settingsManager = locator<SettingsRepository>();
    final InAppReviewService inAppReviewService = locator<InAppReviewService>();

    DateTime? ratingTimerFlagDate = settingsManager.rating.timer;
    final hasRatingBeenRequested = settingsManager.rating.hasBeenRequested;

    // If the user is already logged in while doing the update containing the In_App_Review PR.
    if (ratingTimerFlagDate == null) {
      final sevenDaysLater = DateTime.now().add(const Duration(days: 7));
      settingsManager.rating.timer = sevenDaysLater;
      ratingTimerFlagDate = sevenDaysLater;
    }

    if (await inAppReviewService.isAvailable() &&
        !hasRatingBeenRequested &&
        DateTime.now().isAfter(ratingTimerFlagDate)) {
      await Future.delayed(const Duration(seconds: 2), () async {
        await inAppReviewService.requestReview();
        settingsManager.rating.hasBeenRequested = true;
      });

      return true;
    }
    return false;
  }

  /// Static flag to track if the animation has been played
  static bool hasAnimationPlayed = false;

  Animation<double> get heightAnimation => progressBarModel.heightAnimation;
  Animation<double> get opacityAnimation => progressBarModel.opacityAnimation;
  Animation<double> get titleAnimation => progressBarModel.titleAnimation;

  /// Slide offset for title and subtitle animations (slide from top)
  /// Vertical slide offset from 0.0 (x), -15.0 (y) to 0 (y)
  //Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - titleAnimation.value));
  Offset get titleSlideOffset => Offset(0.0, -15.0 * (1 - progressBarModel.titleAnimation.value));

  /// Fade-in opacity based on title animation progress
  //double get titleFadeOpacity => titleAnimation.value;
  double get titleFadeOpacity => progressBarModel.titleAnimation.value;

  Future<void> init(TickerProvider ticker) async {
    progressBarModel.init(ticker);
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
      loadDynamicMessage(),
      progressBarModel.futureToRun(),
      gradesModel.futureToRun(),
      scheduleModel.futureToRun(),
      sessionReminderModel.futureToRun(),
    ]);
  }

  /// Load the dynamic message based on session context
  Future<void> loadDynamicMessage({bool forceRefresh = false}) async {
    setBusyForObject(dynamicMessageText, true);
    try {
      if (_courseRepository.sessions == null || _courseRepository.sessions!.isEmpty) {
        await _courseRepository.getSessions();
      }

      final now = _settingsManager.dateTimeNow;
      final upcomingSessions = _courseRepository.upcomingSessions;
      final nextSessionStartDate = upcomingSessions.isNotEmpty ? upcomingSessions.first.startDate : null;

      if (_courseRepository.activeSessions.isEmpty) {
        final message = _dynamicMessagesService.determineMessageWithoutActiveSession(
          now: now,
          nextSessionStartDate: nextSessionStartDate,
        );
        dynamicMessageText = message?.resolve(_appIntl);
        notifyListeners();
        return;
      }

      final session = _courseRepository.activeSessions.first;
      await _courseRepository.getCoursesActivities(fromCacheOnly: true);
      final activities = _courseRepository.coursesActivities ?? [];
      await _courseRepository.getReplacedDays(forceRefresh: forceRefresh);
      final replacedDays = _courseRepository.replacedDays ?? [];

      final context = DynamicMessageContext.fromSession(
        session: session,
        activities: activities,
        replacedDays: replacedDays,
        now: now,
        nextSessionStartDate: nextSessionStartDate,
      );

      final message = _dynamicMessagesService.determineMessage(context);
      dynamicMessageText = message.resolve(_appIntl);
      notifyListeners();
    } catch (e) {
      dynamicMessageText = null;
      notifyListeners();
    } finally {
      setBusyForObject(dynamicMessageText, false);
    }
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
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
    progressBarModel.removeListener(notifyListeners);
    progressBarModel.dispose();
    gradesModel.removeListener(notifyListeners);
    gradesModel.dispose();
    scheduleModel.removeListener(notifyListeners);
    scheduleModel.dispose();
    sessionReminderModel.removeListener(notifyListeners);
    sessionReminderModel.dispose();
    super.dispose();
  }
}
