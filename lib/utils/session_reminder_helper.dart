// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/session_reminder_type.dart';

class SessionReminderHelper {
  /// Returns the next upcoming (or today's) session reminder, or null if all dates have passed.
  static SessionReminder? getActiveReminder(Session session, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    final entries = <MapEntry<DateTime, SessionReminderType>>[
      MapEntry(session.startDate, SessionReminderType.sessionStart),
      MapEntry(session.startDateRegistration, SessionReminderType.registrationStart),
      MapEntry(session.deadlineRegistration, SessionReminderType.registrationDeadline),
      MapEntry(session.startDateCancellationWithRefund, SessionReminderType.cancellationWithRefundStart),
      MapEntry(session.deadlineCancellationWithRefund, SessionReminderType.cancellationWithRefundDeadline),
      MapEntry(
        session.deadlineCancellationWithRefundNewStudent,
        SessionReminderType.cancellationWithRefundNewStudentDeadline,
      ),
      MapEntry(
        session.startDateCancellationWithoutRefundNewStudent,
        SessionReminderType.cancellationWithoutRefundNewStudentStart,
      ),
      MapEntry(
        session.deadlineCancellationWithoutRefundNewStudent,
        SessionReminderType.cancellationWithoutRefundNewStudentDeadline,
      ),
      MapEntry(session.deadlineCancellationASEQ, SessionReminderType.cancellationASEQDeadline),
    ];

    entries.sort((a, b) => a.key.compareTo(b.key));

    for (final entry in entries) {
      final entryDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (!entryDate.isBefore(today)) {
        return SessionReminder(type: entry.value, date: entry.key, daysUntil: entryDate.difference(today).inDays);
      }
    }

    return null;
  }

  /// Returns all upcoming (including today's) session reminders, sorted by date.
  static List<SessionReminder> getAllUpcomingReminders(Session session, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    final entries = <MapEntry<DateTime, SessionReminderType>>[
      MapEntry(session.startDate, SessionReminderType.sessionStart),
      MapEntry(session.startDateRegistration, SessionReminderType.registrationStart),
      MapEntry(session.deadlineRegistration, SessionReminderType.registrationDeadline),
      MapEntry(session.startDateCancellationWithRefund, SessionReminderType.cancellationWithRefundStart),
      MapEntry(session.deadlineCancellationWithRefund, SessionReminderType.cancellationWithRefundDeadline),
      MapEntry(
        session.deadlineCancellationWithRefundNewStudent,
        SessionReminderType.cancellationWithRefundNewStudentDeadline,
      ),
      MapEntry(
        session.startDateCancellationWithoutRefundNewStudent,
        SessionReminderType.cancellationWithoutRefundNewStudentStart,
      ),
      MapEntry(
        session.deadlineCancellationWithoutRefundNewStudent,
        SessionReminderType.cancellationWithoutRefundNewStudentDeadline,
      ),
      MapEntry(session.deadlineCancellationASEQ, SessionReminderType.cancellationASEQDeadline),
    ];

    entries.sort((a, b) => a.key.compareTo(b.key));

    final reminders = <SessionReminder>[];
    for (final entry in entries) {
      final entryDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      if (!entryDate.isBefore(today)) {
        reminders.add(
          SessionReminder(type: entry.value, date: entry.key, daysUntil: entryDate.difference(today).inDays),
        );
      }
    }

    return reminders;
  }

  /// Returns all upcoming reminders that share the same date as the active reminder.
  /// Returns empty list if there is no active reminder.
  static List<SessionReminder> getSameDayReminders(Session session, DateTime now) {
    final active = getActiveReminder(session, now);
    if (active == null) return [];

    final activeDate = DateTime(active.date.year, active.date.month, active.date.day);
    final all = getAllUpcomingReminders(session, now);

    return all.where((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate.isAtSameMomentAs(activeDate);
    }).toList();
  }
}
