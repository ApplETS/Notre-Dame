import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';

import 'package:notredame/domain/models/progress_bar_text_options.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';

class SessionProgressUseCase extends ChangeNotifier {
  final _listSessionsRepository = locator<ListSessionsRepository>();

  String? progressBarText;

  ProgressBarText _currentProgressBarText = ProgressBarText.daysElapsedWithTotalDays;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  SessionProgressUseCase() {
    _listSessionsRepository.itemsListenable.observe((sessions) => futureToRunSessionProgressBar());
    _listSessionsRepository.getSessions(forceUpdate: true);
  }

  /// Return session progress based on today's [date]
  double getSessionProgress() {
    if (_courseRepository.activeSessions.isEmpty) {
      return -1.0;
    } else {
      return sessionDays[0] / sessionDays[1];
    }
  }

  
  String getProgressBarText(BuildContext context) {
    switch (_currentProgressBarText) {
      case ProgressBarText.daysElapsedWithTotalDays:
        _currentProgressBarText = ProgressBarText.daysElapsedWithTotalDays;
        return AppIntl.of(context)!.progress_bar_message(sessionDays[0], sessionDays[1]);
      case ProgressBarText.percentage:
        _currentProgressBarText = ProgressBarText.percentage;
        final percentage = sessionDays[1] == 0 ? 0 : ((sessionDays[0] / sessionDays[1]) * 100).round();
        return AppIntl.of(context)!.progress_bar_message_percentage(percentage);
      default:
        _currentProgressBarText = ProgressBarText.remainingDays;
        return AppIntl.of(context)!.progress_bar_message_remaining_days(sessionDays[1] - sessionDays[0]);
    }
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    try {
      final progressBarText = await _settingsManager.getString(PreferencesFlag.progressBarText) ??
          ProgressBarText.daysElapsedWithTotalDays.toString();

      _currentProgressBarText = ProgressBarText.values.firstWhere((e) => e.toString() == progressBarText);

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

  /// Returns a list containing the number of elapsed days in the active session
  /// and the total number of days in the session
  List<int> getSessionDays() {
    if (_courseRepository.activeSessions.isEmpty) {
      return [0, 0];
    } else {
      int dayCompleted =
          _settingsManager.dateTimeNow.difference(_courseRepository.activeSessions.first.startDate).inDays;
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

  void changeProgressBarText() {
    if (_currentProgressBarText.index <= 1) {
      _currentProgressBarText = ProgressBarText.values[_currentProgressBarText.index + 1];
    } else {
      _currentProgressBarText = ProgressBarText.values[0];
    }

    notifyListeners();
    _settingsManager.setString(PreferencesFlag.progressBarText, _currentProgressBarText.toString());
  }
  
  
}