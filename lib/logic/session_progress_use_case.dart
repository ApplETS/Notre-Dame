import 'dart:async';

import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';

import 'package:notredame/domain/models/progress_bar_text_options.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/locator.dart';

import '../l10n/app_localizations.dart';

class SessionProgressUseCase {
  final _listSessionsRepository = locator<ListSessionsRepository>();
  final _settingsRepository = locator<SettingsRepository>();

  var _currentTextStyle = ProgressBarText.daysElapsedWithTotalDays;
  final AppIntl _intl;

  final _controller = StreamController<SessionProgress>.broadcast();
  Stream<SessionProgress> get stream => _controller.stream;
  StreamSubscription? _subscription;

  SessionProgressUseCase(this._intl);

  Future<void> init() async {
      final progressBarText = await _settingsRepository.getString(PreferencesFlag.progressBarText) ??
          ProgressBarText.daysElapsedWithTotalDays.toString();

      _currentTextStyle = ProgressBarText.values.firstWhere((e) => e.toString() == progressBarText);

      _subscription = _listSessionsRepository.stream.listen((sessions) => _runSessionProgressBar(), onError: (error) {
        _controller.addError(error as Object);
      });
      await _listSessionsRepository.getSessions();
  }

  void _runSessionProgressBar() {
    _controller.add(SessionProgress(
      _getSessionProgressPercentage(),
      _getProgressBarText(),
    ));
  }

  /// Return session progress based on today's [date]
  double _getSessionProgressPercentage() {
    final activeSession = _listSessionsRepository.getActiveSession();

    if (activeSession == null) {
      return 0.0;
    }

    return activeSession.daysCompleted / activeSession.totalDays;
  }

  
  String _getProgressBarText() {
    final sessionDays = _listSessionsRepository.getActiveSession();
    final elapsedDays = sessionDays?.daysCompleted ?? 0;
    final totalDays = sessionDays?.totalDays ?? 0;

    switch (_currentTextStyle) {
      case ProgressBarText.daysElapsedWithTotalDays:
        _currentTextStyle = ProgressBarText.daysElapsedWithTotalDays;
        return _intl.progress_bar_message(elapsedDays, totalDays);
      case ProgressBarText.percentage:
        _currentTextStyle = ProgressBarText.percentage;
        final percentage = (_getSessionProgressPercentage() * 100).round();
        return _intl.progress_bar_message_percentage(percentage);
      default:
        _currentTextStyle = ProgressBarText.remainingDays;
        return _intl.progress_bar_message_remaining_days(totalDays - elapsedDays);
    }
  }

  void changeProgressBarText() {
    if (_currentTextStyle.index <= 1) {
      _currentTextStyle = ProgressBarText.values[_currentTextStyle.index + 1];
    } else {
      _currentTextStyle = ProgressBarText.values[0];
    }

    _settingsRepository.setString(PreferencesFlag.progressBarText, _currentTextStyle.toString());
    _runSessionProgressBar();
  }

  Future<void> fetch({bool forceUpdate = false}) async {
    await _listSessionsRepository.getSessions(forceUpdate: forceUpdate);
  }

  void dispose() {
    _controller.close();
    _subscription?.cancel();
  }
  
}