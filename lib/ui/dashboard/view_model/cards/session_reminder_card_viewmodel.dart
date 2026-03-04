// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/session_reminder_helper.dart';

class SessionReminderCardViewmodel extends FutureViewModel {
  final AppIntl _appIntl;

  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Next upcoming session reminder event
  SessionReminder? sessionReminder;

  /// All upcoming session reminders
  List<SessionReminder> allSessionReminders = [];

  /// Reminders for the carouselF
  List<SessionReminder> carouselReminders = [];

  SessionReminderCardViewmodel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<void> futureToRun() async {
    if (_courseRepository.sessions == null || _courseRepository.sessions!.isEmpty) {
      await _courseRepository.getSessions();
    }

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
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
