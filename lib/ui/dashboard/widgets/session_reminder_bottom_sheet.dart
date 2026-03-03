// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/modal_bottom_sheet_layout.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_utils.dart';

class SessionReminderBottomSheet extends StatelessWidget {
  final List<SessionReminder> reminders;

  const SessionReminderBottomSheet({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final intl = AppIntl.of(context)!;

    return ModalBottomSheetLayout(
      title: Text(
        intl.session_reminder_bottom_sheet_title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [for (final reminder in reminders) _reminderRow(context, intl, reminder)],
      ),
    );
  }

  Widget _reminderRow(BuildContext context, AppIntl intl, SessionReminder reminder) {
    final isToday = reminder.daysUntil == 0;
    final timingText = sessionReminderTimingText(intl, context, reminder, long: true);

    return Row(
      spacing: 12.0,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppPalette.etsLightRed.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(reminder.type.icon, size: 24, color: AppPalette.etsLightRed),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sessionReminderEventName(intl, reminder.type),
                style: TextStyle(fontSize: 16, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500),
              ),
              Text(
                timingText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                  color: isToday ? AppPalette.etsLightRed : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
