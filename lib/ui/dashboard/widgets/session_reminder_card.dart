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
import 'package:notredame/ui/core/themes/app_palette.dart';
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: context.theme.appColors.dashboardCard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Bone.icon(size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Bone.text(words: 2),
                const SizedBox(height: 6),
                const Bone.text(words: 3),
              ],
            ),
          ],
        ),
      );
    }

    if (reminder == null) {
      return Center(
        child: Text(
          intl.session_reminder_none, 
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppPalette.etsLightRed.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            reminder!.type.icon,
            size: 24,
            color: AppPalette.etsLightRed,
          ),
        ),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              _eventName(intl, reminder!.type),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              minFontSize: 12,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              _timingText(intl, context),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      case SessionReminderType.cancellationWithoutRefundNewStudentStart:
        return intl.session_reminder_cancellation_no_refund_new_student_start;
      case SessionReminderType.cancellationWithoutRefundNewStudentDeadline:
        return intl.session_reminder_cancellation_no_refund_new_student_deadline;
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
