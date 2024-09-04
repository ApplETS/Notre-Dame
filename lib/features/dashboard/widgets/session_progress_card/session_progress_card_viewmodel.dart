import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';

import 'package:notredame/constants/preferences_flags.dart';

import 'package:notredame/features/dashboard/progress_bar_text_options.dart';

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
  Future<double> futureToRun() {
    return futureToRunSessionProgressBar();
  }

  Future<double> futureToRunSessionProgressBar() async {
    try {
      _progressBarTextSetting = await _getProgressBarTextSetting();

      await _courseRepository.getSessions();

      final sessionDays = getSessionDays();
      _progressBarText = _getProgressBarText(sessionDays.$1, sessionDays.$2);
      return getSessionProgress(sessionDays.$1, sessionDays.$2);
    } catch (error) {
      onError(error);
    }

    return 0.0;
  }

  /// Returns the number of elapsed days in the active session
  /// and the total number of days in the session
  (int, int) getSessionDays() {
    if (_courseRepository.activeSessions.isEmpty) {
      return (0, 0);
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

      return (dayCompleted, dayInTheSession);
    }
  }

  /// Return session progress based on today's [date]
  double getSessionProgress(int daysElapsed, int daysInSession) {
    if (_courseRepository.activeSessions.isEmpty) {
      return -1.0;
    } else {
      return daysElapsed / daysInSession;
    }
  }

  void updateProgressBarTextSetting() {
    if (_progressBarTextSetting.index <= 1) {
      _progressBarTextSetting =
        ProgressBarText.values[_progressBarTextSetting.index + 1];
    } else {
      _progressBarTextSetting = ProgressBarText.values[0];
    }

    _settingsManager.setString(
        PreferencesFlag.progressBarText, _progressBarTextSetting.toString());
    final sessionDays = getSessionDays();
    _progressBarText = _getProgressBarText(sessionDays.$1, sessionDays.$2);
    notifyListeners();
  }

  Future<ProgressBarText> _getProgressBarTextSetting() async {
    final progressBarText =
        await _settingsManager.getString(PreferencesFlag.progressBarText) ??
        ProgressBarText.daysElapsedWithTotalDays.toString();

    return ProgressBarText.values
        .firstWhere((e) => e.toString() == progressBarText);
  }

  String _getProgressBarText(int daysElapsed, int daysInSession) {
    if (_progressBarTextSetting == ProgressBarText.daysElapsedWithTotalDays) {
      return _appIntl.progress_bar_message(daysElapsed, daysInSession);
    } else if (_progressBarTextSetting == ProgressBarText.percentage) {
      return _appIntl.progress_bar_message_percentage(
            ((daysElapsed / daysInSession) * 100).round());
    } else {
      return _appIntl.progress_bar_message_remaining_days(daysInSession - daysElapsed);
    }
  }
}
