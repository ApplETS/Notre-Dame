// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/l10n/app_localizations.dart';

String sessionReminderEventName(AppIntl intl, SessionReminderType type) {
  switch (type) {
    case SessionReminderType.sessionStart:
      return intl.session_reminder_session_start;
    case SessionReminderType.registrationStart:
      return intl.session_reminder_registration_start;
    case SessionReminderType.registrationDeadline:
      return intl.session_reminder_registration_deadline;
    case SessionReminderType.cancellationWithRefundStart:
      return intl.session_reminder_cancellation_refund_start;
    case SessionReminderType.cancellationWithRefundDeadline:
      return intl.session_reminder_cancellation_refund_deadline;
    case SessionReminderType.cancellationWithRefundNewStudentDeadline:
      return intl.session_reminder_cancellation_refund_new_student;
    case SessionReminderType.cancellationWithoutRefundNewStudentStart:
      return intl.session_reminder_cancellation_no_refund_new_student_start;
    case SessionReminderType.cancellationWithoutRefundNewStudentDeadline:
      return intl.session_reminder_cancellation_no_refund_new_student_deadline;
    case SessionReminderType.cancellationASEQDeadline:
      return intl.session_reminder_cancellation_aseq;
  }
}

String sessionReminderTimingText(AppIntl intl, BuildContext context, SessionReminder reminder) {
  if (reminder.daysUntil == 0) {
    return intl.session_reminder_today;
  }
  final locale = Localizations.localeOf(context).languageCode;
  final formattedDate = DateFormat.MMMd(locale).format(reminder.date);
  return intl.session_reminder_in_days(reminder.daysUntil, formattedDate);
}
