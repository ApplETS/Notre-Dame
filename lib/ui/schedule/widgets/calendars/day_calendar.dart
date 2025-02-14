import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/view_model/calendars/day_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/day_view_header.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';

class DayCalendar extends StatefulWidget {
  final GlobalKey<DayViewState> dayViewKey;
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

  const DayCalendar({
    super.key,
    required this.dayViewKey
  });

  @override
  State<DayCalendar> createState() => _DayCalendarState();
}

class _DayCalendarState extends State<DayCalendar> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DayViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Column(children: [
        DayViewHeader(model: model, dayViewKey: widget.dayViewKey),
        model.calendarViewSetting
            ? _buildCalendar(model)
            : _buildListView(model)
      ]),
    );
  }

  Widget _buildCalendar(DayViewModel model) {
    final double heightPerMinute = (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);

    return Expanded(
        child: DayView(
            showVerticalLine: false,
            dayTitleBuilder: DayHeader.hidden,
            key: widget.dayViewKey,
            controller: model.eventController,
            onPageChange: (date, page) => ({
              setState(() {
                model.handleDateSelectedChanged(date);
              })
            }),
            backgroundColor: context.theme.scaffoldBackgroundColor,
            initialDay: model.daySelected,
            hourIndicatorSettings: HourIndicatorSettings(
              color: context.theme.appColors.scheduleLine,
            ),
            liveTimeIndicatorSettings:
            LiveTimeIndicatorSettings(
              color: context.theme.textTheme.bodyMedium!.color!,
            ),
            heightPerMinute: heightPerMinute,
            scrollOffset: heightPerMinute * 60 * 7.5,
            keepScrollOffset: true,
            dateStringBuilder: (date, {secondaryDate}) {
              final locale = AppIntl.of(context)!.localeName;
              return '${date.day} ${DateFormat.MMMM(locale).format(date)} ${date.year}';
            },
            timeStringBuilder: (date, {secondaryDate}) {
              return DateFormat('H:mm').format(date);
            },
            eventTileBuilder:
                (date, events, boundary, startDuration, endDuration) =>
                _buildEventTile(events)));
  }

  Widget _buildListView(DayViewModel model) {
    return Expanded(
      child: GestureDetector(
        onPanEnd: (pan) {
          if (pan.velocity.pixelsPerSecond.dx.abs() > 5) {
            setState(() {
              final int numberOfDays = pan.velocity.pixelsPerSecond.dx.sign.toInt();
              final DateTime newFocusedDate =
              model.daySelected.subtract(Duration(days: numberOfDays));
              model.handleDateSelectedChanged(newFocusedDate);
              HapticFeedback.lightImpact();
            });
          }
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 8.0),
            const Divider(indent: 8.0, endIndent: 8.0, thickness: 1),
            const SizedBox(height: 6.0),
            _buildTitleForDate(model.daySelected),
            const SizedBox(height: 2.0),
            if (model.selectedWeekCalendarEvents().isEmpty && !model.isBusy)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child:
                Center(child: Text(AppIntl.of(context)!.schedule_no_event)),
              )
            else
              // TODO make more elegant
              _buildEventList(model.coursesActivitiesFor(model.daySelected)),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(List<CalendarEventData<dynamic>> events) {
    if (events.isNotEmpty) {
      return ScheduleCalendarTile(
        title: events[0].title,
        description: events[0].description,
        start: events[0].startTime,
        end: events[0].endTime,
        titleStyle: TextStyle(
          fontSize: 14,
          color: events[0].color.accent,
        ),
        totalEvents: events.length,
        padding: const EdgeInsets.all(7.0),
        backgroundColor: events[0].color,
        borderRadius: BorderRadius.circular(6.0),
        buildContext: context,
      );
    } else {
      return Container();
    }
  }

  Widget _buildTitleForDate(DateTime date) => Center(
      child: Text(
        DateFormat.MMMMEEEEd(AppIntl.of(context)!.localeName).format(date),
        style: Theme.of(context).textTheme.headlineMedium,
      ));

  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }
}
