import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/l10n/app_localizations.dart';

class SessionProgressViewmodel extends FutureViewModel {
  final _listSessionsRepository = locator<ListSessionsRepository>();
  final AppIntl _appIntl;


  bool get hasSession => _sessionProgress != null;
  double? get sessionProgress => _sessionProgress?.percentage;
  int? get daysRemaining => _sessionProgress?.daysRemaining;

  StreamSubscription? _subscription;
  SessionProgress? _sessionProgress;
  
  SessionProgressViewmodel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<void> futureToRun() async {
    try {
      setBusy(true);
      _subscription = _listSessionsRepository.stream.listen(
        (sessions) => _runSessionProgressBar(),
        onError: (error) {
          onError(error, null);
        },
      );
      await _listSessionsRepository.getSessions();
    } catch (e) {
      onError(e, null);
    }
  }

  void _runSessionProgressBar() {
    _sessionProgress = SessionProgress(_getSessionProgressPercentage(), _getDaysRemaining());
    setBusy(false);
    notifyListeners();
  }

  /// Return session progress based on today's [date]
  double _getSessionProgressPercentage() {
    final activeSession = _listSessionsRepository.getActiveSession();

    if (activeSession == null) {
      return 0.0;
    }

    return activeSession.daysCompleted / activeSession.totalDays;
  }

  int _getDaysRemaining() {
    final session = _listSessionsRepository.getActiveSession();
    final elapsedDays = session?.daysCompleted ?? 0;
    final totalDays = session?.totalDays ?? 0;
    int remainingDays = totalDays - elapsedDays;

    remainingDays = remainingDays > totalDays ? totalDays : remainingDays;

    return remainingDays >= 0 ? remainingDays : 0;
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}