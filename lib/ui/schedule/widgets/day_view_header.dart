import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/schedule/view_model/calendars/day_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DayViewHeader extends StatefulWidget {
  final DayViewModel model;
  final GlobalKey<calendar_view.DayViewState> dayViewKey;

  const DayViewHeader({
    super.key,
    required this.model,
    required this.dayViewKey
  });

  @override
  State<DayViewHeader> createState() => _DayViewHeaderState();
}

class _DayViewHeaderState extends State<DayViewHeader> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = AppPalette.etsLightRed;
    final Color todayColor = context.theme.appColors.dayIndicatorWeekView;
    final Color defaultColor = context.theme.appColors.scheduleLine;

    return ViewModelBuilder<DayViewModel>.reactive(
      viewModelBuilder: () => widget.model,
      builder: (context, model, child) => TableCalendar(
        key: const Key("TableCalendar"),
        locale: AppIntl.of(context)!.localeName,
        selectedDayPredicate: (day) {
          return isSameDay(model.daySelected, day);
        },
        headerStyle: HeaderStyle(
            titleTextFormatter: (date, locale) =>
                DateFormat.MMMMEEEEd(locale).format(model.daySelected),
            titleCentered: true,
            formatButtonVisible: false),
        eventLoader: model.coursesActivitiesFor,
        calendarFormat: CalendarFormat.week,
        focusedDay: model.daySelected,
        calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) =>
                _buildSelectedDate(date, defaultColor, model, widget.dayViewKey),
            outsideBuilder: (context, date, _) =>
                _buildSelectedDate(date, defaultColor, model, widget.dayViewKey),
            todayBuilder: (context, date, _) =>
                _buildSelectedDate(date, todayColor, model, widget.dayViewKey),
            selectedBuilder: (context, date, _) => FadeTransition(
              opacity:
              Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: _buildSelectedDate(
                  date, selectedColor, model, widget.dayViewKey),
            ),
            markerBuilder: (context, date, events) {
              final bool isSelected = isSameDay(date, model.daySelected);
              final bool isToday = isSameDay(date, DateTime.now());
              final Color color = isSelected
                  ? selectedColor
                  : isToday
                  ? todayColor
                  : defaultColor;
              return _buildEventsMarker(model, date, events, color);
            }),
        // Those are now required by the package table_calendar ^3.0.0. In the doc,
        // it is suggest to set them to values that won't affect user experience.
        // Outside the range, the date are set to disable so no event can be loaded.
        firstDay: DateTime.utc(2010, 12, 31),
        lastDay: DateTime.utc(2100, 12, 31),
      ),
    );
  }

  /// Build the visual for the selected [date]. The [color] parameter set the color for the tile.
  Widget _buildSelectedDate(DateTime date, Color color, DayViewModel model, GlobalKey<calendar_view.DayViewState> dayViewKey) =>
      Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            DateTime startingDate = model.daySelected;
            setState(() {
              model.handleDateSelectedChanged(date);
            });

            if (model.daySelected.difference(startingDate).inDays.abs() == 1) {
              dayViewKey.currentState?.animateToDate(model.daySelected);
            } else {
              dayViewKey.currentState?.jumpToDate(model.daySelected);
            }
          },
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            width: 100,
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle().copyWith(
                    fontSize: 16.0,
                    height: 1.2,
                  ),
                ),
                if (date.month != DateTime.now().month ||
                    date.year != DateTime.now().year)
                  Text(DateFormat.MMM(AppIntl.of(context)!.localeName).format(date),
                      style: const TextStyle(fontSize: 10.0)),
              ],
            ),
          ),
        ),
      );

  /// Build the square with the number of [events] for the [date]
  Widget? _buildEventsMarker(
      DayViewModel model, DateTime date, List events, Color color) {
    if (events.isNotEmpty) {
      return Positioned(
        right: 1,
        bottom: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: color),
          width: 16.0,
          height: 16.0,
          child: Center(
            child: Text(
              '${events.length}',
              style: const TextStyle().copyWith(
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      );
    }
    return null;
  }
}

