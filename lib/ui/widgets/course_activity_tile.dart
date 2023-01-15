// FLUTTER / DART / THIRD-PARTIES
// MODELS
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';

class CourseActivityTile extends StatelessWidget {
  /// Course to display
  final CourseActivity activity;

  final VoidCallback onLongPressedAction;

  final ScheduleViewModel scheduleViewModel;

  DateFormat get timeFormat => DateFormat.Hm();

  /// Display an [activity] with the start and end time of the activity,
  /// it name, shortname, type of activity and local.
  const CourseActivityTile(
      {this.activity, this.onLongPressedAction, this.scheduleViewModel});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0),
        child: ListTile(
          leading: _buildLeading(),
          dense: false,
          title: Text(activity.courseGroup),
          subtitle:
              Text("${activity.courseName}\n${activity.activityDescription}"),
          trailing: Text(activity.activityLocation),
          onLongPress: onLongPressed,
        ),
      );

  Widget _buildLeading() => ConstrainedBox(
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
                Text(timeFormat.format(activity.startDateTime)),
                Text(timeFormat.format(activity.endDateTime)),
              ],
            ),
            VerticalDivider(color: colorFor(activity.courseName), thickness: 2)
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

  void onLongPressed() {
    if (scheduleViewModel.doesCourseActivityBelongToMultipleGroup(activity)) {
      onLongPressedAction();
    }
  }
}
