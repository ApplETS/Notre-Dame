// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class SessionReminderCard extends StatelessWidget {
  final SessionReminder? reminder;
  final bool loading;

  const SessionReminderCard({super.key, required this.reminder, required this.loading});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        color: context.theme.appColors.dashboardCard,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final intl = AppIntl.of(context)!;

    if (loading) {
      return Skeletonizer(
        enabled: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Bone.text(words: 2),
            const SizedBox(height: 8),
            Bone.circle(size: 32),
            const SizedBox(height: 8),
            Bone.text(words: 3),
          ],
        ),
      );
    }

    if (reminder == null) {
      return Center(
        child: Text(intl.session_reminder_none, textAlign: TextAlign.center),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(reminder!.type.icon, size: 40, weight: 100),
        const SizedBox(height: 4),
        AutoSizeText(
          _eventName(intl, reminder!.type),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        AutoSizeText(
          _timingText(intl, context),
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _eventName(AppIntl intl, SessionReminderType type) {
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
      case SessionReminderType.cancellationASEQDeadline:
        return intl.session_reminder_cancellation_aseq;
    }
  }

  String _timingText(AppIntl intl, BuildContext context) {
    if (reminder!.daysUntil == 0) {
      return intl.session_reminder_today;
    }
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat.MMMd(locale).format(reminder!.date);
    return intl.session_reminder_in_days(reminder!.daysUntil, formattedDate);
  }
}
