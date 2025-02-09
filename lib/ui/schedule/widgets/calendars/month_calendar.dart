import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import '../../view_model/schedule_viewmodel.dart';

class MonthCalendar extends StatelessWidget {
  final ScheduleViewModel model;
  final EventController eventController;
  final GlobalKey monthViewKey;
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

  const MonthCalendar({
    super.key,
    required this.model,
    required this.eventController,
    required this.monthViewKey
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}