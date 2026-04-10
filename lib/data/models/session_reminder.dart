// Project imports:
import 'package:notredame/domain/session_reminder_type.dart';

class SessionReminder {
  final SessionReminderType type;
  final DateTime date;
  final int daysUntil;
  final String? sessionName;

  const SessionReminder({required this.type, required this.date, required this.daysUntil, this.sessionName});
}
