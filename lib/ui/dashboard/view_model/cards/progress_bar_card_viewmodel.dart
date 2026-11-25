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
  static const String tag = "ProgressBarCardViewmodel";

  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final SessionProgressUseCase _sessionProgressUseCase;

  StreamSubscription? _sessionProgressSubscription;

  final AppIntl _appIntl;

  SessionProgress? sessionProgress;

  /// if the progress bar is displaying the days remaining or another alternative
  bool _showingPercentage = false;

  bool get showingPercentage => _showingPercentage;

  /// True until the first session progress is received.
  bool get loading => sessionProgress == null;

  double get progress => sessionProgress?.percentage ?? 0.0;

  /// Number of days remaining in the session.
  String get daysRemainingText => sessionProgress?.daysRemaining.toString() ?? "XX";

  /// Percentage of the session completed.
  String get percentageText => sessionProgress != null ? (sessionProgress!.percentage * 100).toStringAsFixed(0) : "XX";

  ProgressBarCardViewmodel({required AppIntl intl})
    : _appIntl = intl,
      _sessionProgressUseCase = SessionProgressUseCase() {
    /// Restore the progress bar display mode from preferences.
    _showingPercentage = _settingsManager.dashboard.displayProgressBarPercentage;
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
    return Future.wait([_sessionProgressUseCase.fetch(forceUpdate: true)]);
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
    _sessionProgressSubscription?.cancel();
    _sessionProgressUseCase.dispose();
    super.dispose();
  }
}
