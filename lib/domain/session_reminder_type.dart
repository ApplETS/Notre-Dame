// Flutter imports:
import 'package:flutter/material.dart';

enum SessionReminderType {
  sessionStart(Icons.school_outlined),
  registrationStart(Icons.app_registration_outlined),
  registrationDeadline(Icons.assignment_late_outlined),
  cancellationWithRefundStart(Icons.monetization_on_outlined),
  cancellationWithRefundDeadline(Icons.money_off_outlined),
  cancellationWithRefundNewStudentDeadline(Icons.person_add_disabled_outlined),
  cancellationASEQDeadline(Icons.health_and_safety_outlined);

  final IconData icon;
  const SessionReminderType(this.icon);
}
