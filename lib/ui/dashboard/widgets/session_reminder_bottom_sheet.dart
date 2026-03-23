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

  bool get _hasMultipleSessions {
    final names = reminders.map((r) => r.sessionName).whereType<String>().toSet();
    return names.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final intl = AppIntl.of(context)!;

    return ModalBottomSheetLayout(
      title: Text(
        intl.session_reminder_bottom_sheet_title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      bodyPadding: EdgeInsets.zero,
      body: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _hasMultipleSessions ? _buildGroupedList(context, intl) : _buildFlatList(context, intl),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFlatList(BuildContext context, AppIntl intl) {
    final widgets = <Widget>[];
    for (int i = 0; i < reminders.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 16.0));
      widgets.add(_reminderRow(context, intl, reminders[i]));
    }
    return widgets;
  }

  List<Widget> _buildGroupedList(BuildContext context, AppIntl intl) {
    final widgets = <Widget>[];
    String? lastSessionName;

    for (int i = 0; i < reminders.length; i++) {
      final reminder = reminders[i];

      if (reminder.sessionName != lastSessionName) {
        if (i > 0) widgets.add(const SizedBox(height: 20.0));
        widgets.add(_sessionHeader(context, reminder.sessionName!));
        widgets.add(const SizedBox(height: 12.0));
        lastSessionName = reminder.sessionName;
      } else {
        widgets.add(const SizedBox(height: 16.0));
      }

      widgets.add(_reminderRow(context, intl, reminder));
    }

    return widgets;
  }

  Widget _sessionHeader(BuildContext context, String sessionName) {
    return Text(
      sessionName,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodySmall?.color,
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
          decoration: BoxDecoration(color: AppPalette.etsLightRed.withValues(alpha: 0.15), shape: BoxShape.circle),
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
