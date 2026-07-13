// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/logic/session_progress_use_case.dart';

class ProgressBarCardViewmodel extends FutureViewModel {
  static const String tag = "DashboardViewModel";

  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final SessionProgressUseCase _sessionProgressUseCase;

  StreamSubscription? _sessionProgressSubscription;

  /// Animation controller for the circle
  AnimationController? _controller;
  late Animation<double> heightAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> titleAnimation;

  /// Getter for the animation controller
  AnimationController get controller => _controller!;

  final AppIntl _appIntl;

  SessionProgress? sessionProgress;

  /// if the progress bar is displaying the days remaining or another alternative
  bool _showingPercentage = false;

  bool get showingPercentage => _showingPercentage;

  ProgressBarCardViewmodel({required AppIntl intl})
    : _appIntl = intl,
      _sessionProgressUseCase = SessionProgressUseCase(),

      /// if the animation has not been played, play it
      shouldPlayAnimation = !hasAnimationPlayed {
    hasAnimationPlayed = true;

    /// Restore the progress bar display mode from preferences.
    _showingPercentage = _settingsManager.dashboard.displayProgressBarPercentage;
  }

  /// Static flag to track if the animation has been played
  static bool hasAnimationPlayed = false;

  /// Tracks if the animation should be played
  final bool shouldPlayAnimation;

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

  @override
  Future futureToRun() async {
    return Future.wait([
      _sessionProgressUseCase.fetch(forceUpdate: true),
    ]);
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  void toggleProgressBarMode() {
    _showingPercentage = !_showingPercentage;
    _settingsManager.dashboard.displayProgressBarPercentage = _showingPercentage;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _sessionProgressSubscription?.cancel();
    _sessionProgressUseCase.dispose();
    super.dispose();
  }
}
