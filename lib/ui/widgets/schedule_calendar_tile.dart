// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ScheduleCalendarTile extends StatefulWidget {
  final String title;
  final String description;
  final TextStyle titleStyle;
  final int totalEvents;
  final EdgeInsets padding;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final DateTime start;
  final DateTime end;
  final BuildContext buildContext;

  const ScheduleCalendarTile(
      {Key key,
      this.title,
      this.description,
      this.titleStyle,
      this.totalEvents,
      this.padding,
      this.backgroundColor,
      this.borderRadius,
      this.start,
      this.end,
      this.buildContext})
      : super(key: key);

  @override
  _ScheduleCalendarTileState createState() => _ScheduleCalendarTileState();
}

class _ScheduleCalendarTileState extends State<ScheduleCalendarTile> {
  void _showTileInfo() {
    final courseInfos = widget.description.split(";");
    final courseName = courseInfos[0].split("-")[0];
    final courseLocation = courseInfos[1];
    final courseType = courseInfos[2];
    final teacherName = courseInfos[3];
    final startTime =
        "${widget.start.hour}:${widget.start.minute.toString().padLeft(2, '0')}";
    final String endTime =
        DateFormat.Hm().format(widget.end.add(const Duration(minutes: 1)));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "$courseName ($courseLocation)",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${AppIntl.of(widget.buildContext).schedule_calendar_by} $teacherName",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${AppIntl.of(widget.buildContext).schedule_calendar_from_time} $startTime ${AppIntl.of(widget.buildContext).schedule_calendar_to_time} $endTime",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              widget.title,
              style: widget.titleStyle,
              maxLines: 3,
            )
          ],
        ),
      ),
    );
  }
}
