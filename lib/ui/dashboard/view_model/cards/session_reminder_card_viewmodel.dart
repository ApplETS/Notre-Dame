// Dart imports:
import 'dart:async';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
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
    // TODO: Remove hardcoded test data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    allSessionReminders = [
      SessionReminder(type: SessionReminderType.registrationDeadline, date: today, daysUntil: 0),
      SessionReminder(type: SessionReminderType.cancellationWithRefundStart, date: today.add(const Duration(days: 1)), daysUntil: 1),
      SessionReminder(type: SessionReminderType.cancellationWithRefundDeadline, date: today.add(const Duration(days: 2)), daysUntil: 2),
      SessionReminder(type: SessionReminderType.cancellationWithRefundNewStudentDeadline, date: today.add(const Duration(days: 3)), daysUntil: 3),
      SessionReminder(type: SessionReminderType.cancellationWithoutRefundNewStudentStart, date: today.add(const Duration(days: 4)), daysUntil: 4),
      SessionReminder(type: SessionReminderType.cancellationWithoutRefundNewStudentDeadline, date: today.add(const Duration(days: 5)), daysUntil: 5),
      SessionReminder(type: SessionReminderType.cancellationASEQDeadline, date: today.add(const Duration(days: 6)), daysUntil: 6),
      SessionReminder(type: SessionReminderType.sessionEnd, date: today.add(const Duration(days: 7)), daysUntil: 7),
    ];
    sessionReminder = allSessionReminders.first;
    carouselReminders = allSessionReminders;
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
