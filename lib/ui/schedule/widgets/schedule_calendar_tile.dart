// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class ScheduleCalendarTile extends StatefulWidget {
  final EventData event;
  final BuildContext buildContext;
  final EdgeInsets? padding;

  const ScheduleCalendarTile({super.key, required this.buildContext, required this.event, this.padding});

  @override
  State<ScheduleCalendarTile> createState() => _ScheduleCalendarTileState();
}

class _ScheduleCalendarTileState extends State<ScheduleCalendarTile> {
  void _showTileInfo() {
    final courseName = widget.event.courseName;
    final courseLocation = widget.event.locations?.join(", ");
    final courseType = widget.event.activityName;
    final teacherName = widget.event.teacherName;
    final startTime = widget.event.startTime == null
        ? AppIntl.of(widget.buildContext)!.grades_not_available
        : "${widget.event.startTime!.hour}:${widget.event.startTime!.minute.toString().padLeft(2, '0')}";
    final endTime = widget.event.endTime == null
        ? AppIntl.of(widget.buildContext)!.grades_not_available
        : DateFormat.Hm().format(widget.event.endTime!.add(const Duration(minutes: 1)));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text(
              "xxcfd",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("courseType", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (teacherName != "null")
                Text(
                  "${AppIntl.of(widget.buildContext)!.schedule_calendar_by} $teacherName",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              Text(
                "${AppIntl.of(widget.buildContext)!.schedule_calendar_from_time} $startTime ${AppIntl.of(widget.buildContext)!.schedule_calendar_to_time} $endTime",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppIntl.of(context)!.close_button_text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(10),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTileInfo,
      child: Container(
        decoration: BoxDecoration(color: widget.event.color, borderRadius: BorderRadius.circular(6.0)),
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    widget.event.courseAcronym,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    minFontSize: 10,
                  ),
                ],
              ),
            ),
            if (widget.event.calendarDescription != null)
              Divider(color: context.theme.textTheme.bodyMedium!.color?.withAlpha(100), height: 4),
            if (widget.event.calendarDescription != null)
              Flexible(
                flex: 2,
                child: AutoSizeText(widget.event.calendarDescription!, minFontSize: 10, maxLines: widget.event.calendarDescriptionLines),
              ),
          ],
        ),
      ),
    );
  }
}
