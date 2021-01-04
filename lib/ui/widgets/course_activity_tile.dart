// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

class CourseActivityTile extends StatelessWidget {
  final CourseActivity activity;

  DateFormat get timeFormat => DateFormat.Hm();

  const CourseActivityTile(this.activity);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0),
        child: ListTile(
          leading: _buildLeading(),
          dense: false,
          title: Text(activity.courseGroup),
          isThreeLine: true,
          subtitle: Text("${activity.courseName}\n${activity.activityDescription}"),
          trailing: Text(activity.activityLocation),
        ),
      );

  Widget _buildLeading() => Container(
        width: 56,
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(timeFormat.format(activity.startDateTime)),
                  Text(timeFormat.format(activity.endDateTime)),
                ],
              ),
            ),
            VerticalDivider(color: colorFor(activity.courseName), thickness: 2)
          ],
        ),
      );

  Color colorFor(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (256 * 256 * 256);
    final red = (finalHash & 0xFF0000) >> 16;
    final blue = (finalHash & 0xFF00) >> 8;
    final green = finalHash & 0xFF;
    final color = Color.fromRGBO(red, green, blue, 1);
    return color;
  }
}
