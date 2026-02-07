// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

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
    final courseLocation = widget.event.locations?.join(", ");
    final courseType = widget.event.activityName;
    final teacherName = widget.event.teacherName;
    final startTime = "${widget.event.startTime.hour}:${widget.event.startTime.minute.toString().padLeft(2, '0')}";
    final endTime = DateFormat.Hm().format(widget.event.endTime.add(const Duration(minutes: 1)));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.group ?? widget.event.courseAcronym,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(widget.event.courseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${AppIntl.of(widget.buildContext)!.schedule_calendar_from_time} $startTime ${AppIntl.of(widget.buildContext)!.schedule_calendar_to_time} $endTime",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              if (courseLocation != null)
                Text(courseLocation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (courseType != null)
                Text(courseType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (teacherName != null)
                Text(
                  "${AppIntl.of(widget.buildContext)!.schedule_calendar_by} $teacherName",
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final aspectRatio = width / height;
          final wideLayout = aspectRatio > 4 || height < 60;
          final isSmall = (width < 80 && height < 80) || width < 40 || height < 40;

          final description = widget.event.calendarDescription(!wideLayout);

          if (isSmall || description == null) {
            return Container(
              decoration: BoxDecoration(color: widget.event.color, borderRadius: BorderRadius.circular(6.0)),
              child: Center(
                child: RotatedBox(
                  quarterTurns: width > 40 ? 0 : 1,
                  child: AutoSizeText(
                    widget.event.courseAcronym,
                    minFontSize: 8,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.grey.white),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(color: widget.event.color, borderRadius: BorderRadius.circular(6.0)),
            child: Flex(
              direction: wideLayout ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: wideLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: wideLayout ? min(70, width / 2.5) : null,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2.5),
                        topRight: Radius.circular(2.5),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AutoSizeText(
                          widget.event.courseAcronym,
                          minFontSize: 8,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.grey.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: widget.padding,
                    child: AutoSizeText(
                      description,
                      minFontSize: 8,
                      maxLines: widget.event.locations!.length + 1,
                      style: TextStyle(color: AppPalette.grey.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
