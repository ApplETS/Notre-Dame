// Dart imports:
import 'dart:async';

// Project imports:
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/session_progress.dart';
import 'package:notredame/locator.dart';

class SessionProgressUseCase {
  final _listSessionsRepository = locator<ListSessionsRepository>();

  final _controller = StreamController<SessionProgress>.broadcast();
  Stream<SessionProgress> get stream => _controller.stream;
  StreamSubscription? _subscription;

  Future<void> init() async {
    _subscription = _listSessionsRepository.stream.listen(
      (sessions) => _runSessionProgressBar(),
      onError: (error) {
        _controller.addError(error as Object);
      },
    );
    await _listSessionsRepository.getSessions();
  }

  void _runSessionProgressBar() {
    _controller.add(SessionProgress(_getSessionProgressPercentage(), _getDaysRemaining()));
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
    final sessionDays = _listSessionsRepository.getActiveSession();
    final elapsedDays = sessionDays?.daysCompleted ?? 0;
    final totalDays = sessionDays?.totalDays ?? 0;

    return totalDays - elapsedDays;
  }

  Future<void> fetch({bool forceUpdate = false}) async {
    await _listSessionsRepository.getSessions(forceUpdate: forceUpdate);
  }

  void dispose() {
    _controller.close();
    _subscription?.cancel();
  }
}
