// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/calendars/month_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

class MonthCalendar extends StatelessWidget {
  final GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  final ScheduleController controller;

  MonthCalendar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MonthViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => _buildMonthView(context, model),
    );
  }

  Widget _buildMonthView(BuildContext context, MonthViewModel model) {
    controller.returnToToday = () {
      model.returnToCurrentDate();
      monthViewKey.currentState?.animateToMonth(DateTime(DateTime.now().year, DateTime.now().month));
    };

    return MonthView(
      key: monthViewKey,
      cellAspectRatio: 0.8,
      borderColor: context.theme.appColors.scheduleLine,
      controller: model.eventController..addAll(model.selectedMonthEvents()),
      safeAreaOption: const SafeAreaOption(top: false, bottom: false),
      useAvailableVerticalSpace: MediaQuery.of(context).size.height >= 500,
      onPageChange: (date, page) => model.handleDateSelectedChanged(date),
      weekDayBuilder: (int value) => WeekDayTile(
        dayIndex: value,
        displayBorder: false,
        textStyle: TextStyle(color: context.theme.textTheme.bodyMedium!.color!),
        backgroundColor: context.theme.appColors.appBar,
        weekDayStringBuilder: (p0) => weekTitles[p0],
      ),
      headerStringBuilder: (date, {secondaryDate}) {
        final locale = AppIntl.of(context)!.localeName;
        return '${DateFormat.MMMM(locale).format(date).characters.first.toUpperCase()}${DateFormat.MMMM(locale).format(date).substring(1)} ${date.year}';
      },
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(color: context.theme.appColors.appBar),
        leftIconConfig: IconDataConfig(color: context.theme.textTheme.bodyMedium!.color!, size: 30),
        rightIconConfig: IconDataConfig(color: context.theme.textTheme.bodyMedium!.color!, size: 30),
      ),
      startDay: WeekDays.sunday,
      initialMonth: DateTime(DateTime.now().year, DateTime.now().month),
      cellBuilder: (date, events, _, _, _) => FilledCell(
        onTileTap: (event, date) => _onDayTapped(context, events as List<CalendarEventTile>, date),
        hideDaysNotInMonth: false,
        titleColor: context.theme.textTheme.bodyMedium!.color!,
        highlightColor: AppPalette.etsLightRed,
        shouldHighlight: date.getDayDifference(DateTime.now()) == 0,
        date: date,
        isInMonth: date.month == DateTime.now().month,
        events: events,
        backgroundColor: (date.month == DateTime.now().month) ? Colors.transparent : Colors.grey.withValues(alpha: .06),
      ),
      onCellTap: (events, date) => _onDayTapped(context, events as List<CalendarEventTile>, date),
    );
  }

  void _onDayTapped(BuildContext context, List<CalendarEventTile> events, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Needed for rounded corners
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
                Container(
                  decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: context.theme.appColors.modalHandle,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        DateFormat.yMMMMd(AppIntl.of(context)!.localeName).format(date),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DayCalendar(
                    listView: false,
                    controller: controller,
                    events: events,
                    selectedDate: date,
                    skipRepositoryLoad: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
