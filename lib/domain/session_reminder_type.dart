// Flutter imports:
import 'package:flutter/material.dart';

enum SessionReminderType {
  sessionStart(Icons.school_outlined),
  registrationStart(Icons.edit_calendar_outlined),
  registrationDeadline(Icons.edit_calendar_outlined),
  cancellationWithRefundStart(Icons.monetization_on_outlined),
  cancellationWithRefundDeadline(Icons.monetization_on_outlined),
  cancellationWithRefundNewStudentDeadline(Icons.monetization_on_outlined),
  cancellationWithoutRefundNewStudentStart(Icons.cancel_outlined),
  cancellationWithoutRefundNewStudentDeadline(Icons.cancel_outlined),
  cancellationASEQDeadline(Icons.health_and_safety_outlined);

  final IconData icon;
  const SessionReminderType(this.icon);
}
