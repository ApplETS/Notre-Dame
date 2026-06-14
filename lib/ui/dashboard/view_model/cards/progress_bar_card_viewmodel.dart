// Dart imports:
import 'dart:async';

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

  /// Get the list of courses for the Grades card.
  @override
  Future<void> futureToRun() async {
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
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  @override
  void dispose() {
    _sessionProgressSubscription?.cancel();
    _sessionProgressUseCase.dispose();
    super.dispose();
  }
}
