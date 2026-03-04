// Dart imports:
import 'dart:async';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/session_reminder_helper.dart';

class SessionReminderCardViewmodel extends FutureViewModel {
  final AppIntl _appIntl;

  final CourseRepository _courseRepository = locator<CourseRepository>();
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
    await _listSessionsRepository.getSessions();
  }

  void _loadSessionReminders() {
    if (_courseRepository.activeSessions.isNotEmpty) {
      final session = _courseRepository.activeSessions.first;
      final now = DateTime.now();
      allSessionReminders = SessionReminderHelper.getAllUpcomingReminders(session, now);
      sessionReminder = allSessionReminders.isEmpty ? null : allSessionReminders.first;
      carouselReminders = SessionReminderHelper.getCarouselReminders(session, now);
    } else {
      sessionReminder = null;
      allSessionReminders = [];
      carouselReminders = [];
    }
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
