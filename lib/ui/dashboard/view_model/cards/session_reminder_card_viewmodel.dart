// Dart imports:
import 'dart:async';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/session_reminder_helper.dart';

class SessionReminderCardViewmodel extends FutureViewModel {
  final AppIntl _appIntl;

  final ListSessionsRepository _listSessionsRepository = locator<ListSessionsRepository>();

  StreamSubscription? _subscription;

  /// Next upcoming session reminder event
  SessionReminder? sessionReminder;

  /// All upcoming session reminders
  List<SessionReminder> allSessionReminders = [];

  /// Reminders for the carousel
  List<SessionReminder> carouselReminders = [];

  SessionReminderCardViewmodel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<void> futureToRun() async {
    _subscription = _listSessionsRepository.stream.listen((_) => _loadSessionReminders(), onError: (_) {});

    if (_listSessionsRepository.getActiveSession() != null ||
        _listSessionsRepository.getNextUpcomingSession() != null) {
      _loadSessionReminders();
      try {
        unawaited(_listSessionsRepository.getSessions().catchError((_) {}));
      } catch (_) {}
    } else {
      await _listSessionsRepository.getSessions();
    }
  }

  void _loadSessionReminders() {
    final activeSession = _listSessionsRepository.getActiveSession();
    final nextSession = _listSessionsRepository.getNextUpcomingSession();

    final sessions = <Session>[
      ?activeSession,
      ?nextSession,
    ];

    if (sessions.isEmpty) {
      sessionReminder = null;
      allSessionReminders = [];
      carouselReminders = [];
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final primarySession = sessions.first;

    allSessionReminders = SessionReminderHelper.getAllUpcomingRemindersMultiSession(sessions, now);
    sessionReminder = SessionReminderHelper.getActiveReminder(primarySession, now);
    carouselReminders = SessionReminderHelper.getCarouselReminders(primarySession, now);
    notifyListeners();
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
