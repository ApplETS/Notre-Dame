// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/session_reminder_type.dart';

class SessionReminderHelper {
  static List<MapEntry<DateTime, SessionReminderType>> _buildSortedEntries(Session session) {
    final entries = <MapEntry<DateTime, SessionReminderType>>[
      MapEntry(session.startDate, SessionReminderType.sessionStart),
      MapEntry(
        session.startDateRegistration.isBefore(session.deadlineRegistration)
            ? session.startDateRegistration
            : session.deadlineRegistration,
        SessionReminderType.registrationStart,
      ),
      MapEntry(
        session.deadlineRegistration.isAfter(session.startDateRegistration)
            ? session.deadlineRegistration
            : session.startDateRegistration,
        SessionReminderType.registrationDeadline,
      ),
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
      MapEntry(session.endDate, SessionReminderType.sessionEnd),
    ];

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Returns the next upcoming (or today's) session reminder, or null if all dates have passed.
  static SessionReminder? getActiveReminder(Session session, DateTime now) {
    final all = getAllUpcomingReminders(session, now);
    return all.isEmpty ? null : all.first;
  }

  /// Returns all upcoming (including today's) session reminders, sorted by date.
  static List<SessionReminder> getAllUpcomingReminders(Session session, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final entries = _buildSortedEntries(session);

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

  static const int defaultCarouselThresholdDays = 7;

  /// Returns reminders for the carousel: always the next upcoming event (even if
  /// beyond threshold), plus all additional events within [thresholdDays] of today.
  /// Returns empty list if no upcoming reminders exist.
  static List<SessionReminder> getCarouselReminders(
    Session session,
    DateTime now, {
    int thresholdDays = defaultCarouselThresholdDays,
  }) {
    final all = getAllUpcomingReminders(session, now);
    if (all.isEmpty) return [];

    final result = <SessionReminder>[all.first];
    for (int i = 1; i < all.length; i++) {
      if (all[i].daysUntil <= thresholdDays) {
        result.add(all[i]);
      }
    }

    return result;
  }
}
