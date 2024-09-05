// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';

class SessionProgressCardViewmodel extends FutureViewModel<double> {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final SettingsManager _settingsManager = locator<SettingsManager>();
  final AppIntl _appIntl;

  SessionProgressCardViewmodel(this._appIntl);

  String? _progressBarText;
  String? get progressBarText => _progressBarText;

  ProgressBarText _progressBarTextSetting =
      ProgressBarText.daysElapsedWithTotalDays;

  @override
  Future<double> futureToRun() async {
    try {
      _progressBarTextSetting = await _getProgressBarTextSetting();

      await _courseRepository.getSessions();

      final sessionDays = _getSessionDays();
      _progressBarText = _getProgressBarText(sessionDays.$1, sessionDays.$2);
      return _getSessionProgress(sessionDays.$1, sessionDays.$2);
    } catch (error) {
      onError(error);
    }

    return 0.0;
  }

  void updateProgressBarTextSetting() {
    _progressBarTextSetting = _progressBarTextSetting.index <= 1
        ? ProgressBarText.values[_progressBarTextSetting.index + 1]
        : ProgressBarText.values[0];

    _settingsManager.setString(
        PreferencesFlag.progressBarText, _progressBarTextSetting.toString());

    final sessionDays = _getSessionDays();
    _progressBarText = _getProgressBarText(sessionDays.$1, sessionDays.$2);
    notifyListeners();
  }

  /// Returns the number of elapsed days in the active session
  /// and the total number of days in the session
  (int, int) _getSessionDays() {
    if (_courseRepository.activeSessions.isEmpty) {
      return (0, 0);
    }

    final session = _courseRepository.activeSessions.first;

    final dayInTheSession = session.endDate
        .difference(session.startDate)
        .inDays;

    final dayCompleted = _settingsManager.dateTimeNow
        .difference(session.startDate)
        .inDays
        .clamp(0, dayInTheSession);

    return (dayCompleted, dayInTheSession);
  }

  /// Return session progress based on today's [date]
  double _getSessionProgress(int daysElapsed, int daysInSession) =>
      _courseRepository.activeSessions.isEmpty
          ? -1.0
          : daysElapsed / daysInSession;

  Future<ProgressBarText> _getProgressBarTextSetting() async {
    final progressBarText =
        await _settingsManager.getString(PreferencesFlag.progressBarText) ??
        ProgressBarText.daysElapsedWithTotalDays.toString();

    return ProgressBarText.values
        .firstWhere((e) => e.toString() == progressBarText);
  }

  String _getProgressBarText(int daysElapsed, int daysInSession) {
    switch (_progressBarTextSetting) {
      case ProgressBarText.daysElapsedWithTotalDays:
        return _appIntl.progress_bar_message(daysElapsed, daysInSession);
      case ProgressBarText.percentage:
        return daysInSession == 0
            ? _appIntl.progress_bar_message_percentage(0)
            : _appIntl.progress_bar_message_percentage(
                ((daysElapsed / daysInSession) * 100).round());
      case ProgressBarText.remainingDays:
        return _appIntl.progress_bar_message_remaining_days(
            daysInSession - daysElapsed);
    }
  }
}
