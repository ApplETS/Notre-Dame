// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:notredame/utils/date_extensions.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/modal_bottom_sheet_header.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/calendars/month_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

class MonthCalendar extends StatefulWidget {
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  final ScheduleController controller;

  const MonthCalendar({super.key, required this.controller});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  final GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MonthViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => _buildMonthView(context, model),
    );
  }

  Widget _buildMonthView(BuildContext context, MonthViewModel model) {
    widget.controller.returnToToday = () {
      model.returnToCurrentDate();
      monthViewKey.currentState?.animateToMonth(DateTime(DateTime.now().year, DateTime.now().month));
    };

    widget.controller.refreshEvents = () async {
      await model.refreshEvents();
      setState(() {});
    };

    return MonthView(
      key: monthViewKey,
      monthViewStyle: MonthViewStyle(
        cellAspectRatio: 0.8,
        safeAreaOption: const SafeAreaOption(top: false, bottom: false, left: false),
        useAvailableVerticalSpace: MediaQuery.of(context).size.height >= 500,
        startDay: WeekDays.sunday,
        initialMonth: DateTime(DateTime.now().year, DateTime.now().month),
      ),
      controller: model.eventController..addAll(model.selectedMonthEvents()),
      monthViewBuilders: MonthViewBuilders(
        onPageChange: (date, page) => model.handleDateSelectedChanged(date),
        weekDayBuilder: (int value) => WeekDayTile(
          dayIndex: value,
          displayBorder: false,
          textStyle: context.theme.textTheme.bodyMedium!,
          weekDayStringBuilder: (p0) => MonthCalendar.weekTitles[p0],
        ),
        headerStringBuilder: (date, {secondaryDate}) {
          final locale = AppIntl.of(context)!.localeName;
          return '${DateFormat.MMMM(locale).format(date).characters.first.toUpperCase()}${DateFormat.MMMM(locale).format(date).substring(1)} ${date.year}';
        },
        cellBuilder: (date, events, _, _, _) => FilledCell(
          hideDaysNotInMonth: false,
          titleColor: context.theme.textTheme.bodyMedium!.color!,
          highlightColor: AppPalette.etsLightRed,
          shouldHighlight: date.getDayDifference(DateTime.now()) == 0,
          date: date,
          events: events,
          backgroundColor: (date.firstDayOfMonth == model.monthSelected.firstDayOfMonth) ? Colors.transparent : Colors.grey.withValues(alpha: .06),
        ),
        onCellTap: (events, date) => _onDayTapped(context, date),
      ),
    );
  }

  void _onDayTapped(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: DraggableScrollableSheet(
          maxChildSize: 0.85,
          minChildSize: 0.5,
          initialChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                ModalBottomSheetHeader(
                  title: Text(
                    DateFormat.yMMMMd(AppIntl.of(context)!.localeName).format(date),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: DayCalendar(listView: false, controller: widget.controller, selectedDate: date),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
