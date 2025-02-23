import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/schedule/view_model/calendars/month_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

import 'calendar_controller.dart';

class MonthCalendar extends StatelessWidget {
  final GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  final CalendarController controller;

  MonthCalendar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MonthViewModel(intl: AppIntl.of(context)!),
      builder:(context, model, child) => _buildMonthView(context, model),
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
      controller: model.eventController,
      safeAreaOption:
      const SafeAreaOption(top: false, bottom: false),
      useAvailableVerticalSpace: MediaQuery.of(context).size.height >= 500,
      onPageChange: (date, page) => model.handleDateSelectedChanged(date),
      weekDayBuilder: (int value) => WeekDayTile(
          dayIndex: value,
          displayBorder: false,
          textStyle:
          TextStyle(color: context.theme.textTheme.bodyMedium!.color!),
          backgroundColor: context.theme.scaffoldBackgroundColor,
          weekDayStringBuilder: (p0) => weekTitles[p0]),
      headerStringBuilder: (date, {secondaryDate}) {
        final locale = AppIntl.of(context)!.localeName;
        return '${DateFormat.MMMM(locale).format(date).characters.first.toUpperCase()}${DateFormat.MMMM(locale).format(date).substring(1)} ${date.year}';
      },
      headerStyle: HeaderStyle(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
          ),
          leftIcon: Icon(
            Icons.chevron_left,
            size: 30,
            color: context.theme.textTheme.bodyMedium!.color,
          ),
          rightIcon: Icon(
            Icons.chevron_right,
            size: 30,
            color: context.theme.textTheme.bodyMedium!.color,
          )),
      weekDayStringBuilder: (p0) {
        return weekTitles[p0];
      },
      startDay: WeekDays.sunday,
      initialMonth: DateTime(DateTime.now().year, DateTime.now().month),
      cellBuilder: (date, events, _, __, ___) => FilledCell(
        hideDaysNotInMonth: false,
        titleColor: context.theme.textTheme.bodyMedium!.color!,
        highlightColor: AppPalette.etsLightRed,
        shouldHighlight: date.getDayDifference(DateTime.now()) == 0,
        date: date,
        isInMonth: date.month == DateTime.now().month,
        events: events,
        backgroundColor: (date.month == DateTime.now().month)
            ? context.theme.scaffoldBackgroundColor
            : Colors.grey.withValues(alpha: .06),
      ),
    );
  }
}