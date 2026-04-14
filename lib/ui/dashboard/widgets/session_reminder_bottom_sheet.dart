// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/modal_bottom_sheet_header.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_utils.dart';
import 'package:notredame/utils/session_reminder_helper.dart';
import 'package:notredame/utils/session_utils.dart';

class SessionReminderBottomSheet extends StatelessWidget {
  final List<SessionReminder> reminders;

  const SessionReminderBottomSheet({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final intl = AppIntl.of(context)!;
    final grouped = SessionReminderHelper.hasMultipleSessions(reminders);

    final double calculatedSize = (0.10 + (reminders.length * 0.10)).clamp(0.20, 0.55);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: DraggableScrollableSheet(
        maxChildSize: calculatedSize,
        minChildSize: 0,
        initialChildSize: calculatedSize,
        shouldCloseOnMinExtent: true,
        snap: true,
        snapSizes: const [],
        expand: false,
        builder: (context, ScrollController scrollController) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final showHeader = constraints.maxHeight > 100;

              return Column(
                children: [
                  if (showHeader)
                    ModalBottomSheetHeader(
                      title: Text(
                        intl.session_reminder_bottom_sheet_title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + MediaQuery.of(context).viewPadding.bottom),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              grouped ? _buildGroupedList(context, intl) : _buildFlatList(context, intl),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
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
        widgets.add(_sessionHeader(context, intl, reminder.sessionName!));
        widgets.add(const SizedBox(height: 12.0));
        lastSessionName = reminder.sessionName;
      } else {
        widgets.add(const SizedBox(height: 16.0));
      }

      widgets.add(_reminderRow(context, intl, reminder));
    }

    return widgets;
  }

  Widget _sessionHeader(BuildContext context, AppIntl intl, String shortName) {
    return Text(
      localizedSessionName(intl, shortName),
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color),
    );
  }

  Widget _reminderRow(BuildContext context, AppIntl intl, SessionReminder reminder) {
    final timingText = sessionReminderDateWithRemaining(intl, context, reminder);

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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(timingText, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ),
      ],
    );
  }
}
