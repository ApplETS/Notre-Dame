// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_bottom_sheet.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_utils.dart';

class SessionReminderCard extends StatelessWidget {
  final SessionReminder? reminder;
  final bool loading;
  final List<SessionReminder> allReminders;

  const SessionReminderCard({super.key, required this.reminder, required this.loading, this.allReminders = const []});

  @override
  Widget build(BuildContext context) {
    final tappable = reminder != null && allReminders.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: context.theme.appColors.dashboardCard,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: tappable
              ? () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  builder: (_) => SessionReminderBottomSheet(reminders: allReminders),
                )
              : null,
          child: Padding(padding: const EdgeInsets.all(16.0), child: _buildContent(context)),
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
              children: [const Bone.text(words: 2), const SizedBox(height: 6), const Bone.text(words: 3)],
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
          decoration: BoxDecoration(color: AppPalette.etsLightRed.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(reminder!.type.icon, size: 24, color: AppPalette.etsLightRed),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              sessionReminderEventName(intl, reminder!.type),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.2),
              minFontSize: 12,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              sessionReminderTimingText(intl, context, reminder!),
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
