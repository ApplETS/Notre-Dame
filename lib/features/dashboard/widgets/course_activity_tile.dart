// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/models/course_activity.dart';

class CourseActivityTile extends StatelessWidget {
  /// Course to display
  final CourseActivity activity;

  DateFormat get timeFormat => DateFormat.Hm();

  /// Display an [activity] with the start and end time of the activity,
  /// it name, shortname, type of activity and local.
  const CourseActivityTile(this.activity);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0),
        child: ListTile(
          leading: _buildLeading(context),
          dense: false,
          title: Text(activity.courseGroup,
              style: Theme.of(context).textTheme.titleSmall),
          subtitle:
              Text("${activity.courseName}\n${activity.activityDescription}"),
          trailing: Text(activity.activityLocation,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      );

  Widget _buildLeading(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 30,
          maxWidth: 86,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeFormat.format(activity.startDateTime),
                    style: Theme.of(context).textTheme.bodySmall),
                Text(timeFormat.format(activity.endDateTime),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            Skeleton.shade(
                child: VerticalDivider(
                    color: colorFor(activity.courseName), thickness: 2))
          ],
        ),
      );

  /// Generate a color based on [text].
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
