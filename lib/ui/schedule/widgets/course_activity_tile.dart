// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import '../../../data/models/calendar_event_tile.dart';

class CourseActivityTile extends StatelessWidget {
  /// Course to display
  final EventData event;

  DateFormat get timeFormat => DateFormat.Hm();

  /// Display an [event] with the start and end time of the activity,
  /// it name, shortname, type of activity and local.
  const CourseActivityTile(this.event, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0),
    child: ListTile(
      leading: _buildLeading(context),
      dense: false,
      title: Text(event.group!, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text("${event.courseName}\n${event.activityName}"),
      trailing: Text(event.locations!.join(", "), style: Theme.of(context).textTheme.bodySmall),
    ),
  );

  Widget _buildLeading(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 30, maxWidth: 86),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(timeFormat.format(event.startTime!), style: Theme.of(context).textTheme.bodySmall),
            Text(timeFormat.format(event.endTime!), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Skeleton.shade(child: VerticalDivider(color: event.color, thickness: 2)),
      ],
    ),
  );
}