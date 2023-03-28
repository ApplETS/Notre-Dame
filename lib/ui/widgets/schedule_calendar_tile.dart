import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

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
      this.end})
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
    final startTime = "${widget.start.hour}:${widget.start.minute}";
    final endTime = "${widget.end.hour}:${widget.end.minute}";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$courseName ($courseLocation)"),
          content: Text(
              "${courseType}, par ${teacherName}\nDe ${startTime} à ${endTime}"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
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
