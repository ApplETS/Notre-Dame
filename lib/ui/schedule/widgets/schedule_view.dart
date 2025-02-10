// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/schedule/view_model/schedule_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/calendar_selector.dart';
import 'package:notredame/ui/schedule/widgets/schedule_settings.dart';


class ScheduleView extends StatefulWidget {
  @visibleForTesting
  final DateTime? initialDay;

  const ScheduleView({super.key, this.initialDay});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  final GlobalKey<calendar_view.WeekViewState> weekViewKey =
      GlobalKey<calendar_view.WeekViewState>();
  final GlobalKey<calendar_view.MonthViewState> monthViewKey =
      GlobalKey<calendar_view.MonthViewState>();
  final GlobalKey<calendar_view.DayViewState> dayViewKey =
      GlobalKey<calendar_view.DayViewState>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  static const String tag = "ScheduleView";

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ScheduleViewModel>.reactive(
        viewModelBuilder: () => ScheduleViewModel(intl: AppIntl.of(context)!),
        onViewModelReady: (model) {
          if (model.settings.isEmpty) {
            model.loadSettings();
          }
        },
        builder: (context, model, child) => BaseScaffold(
            isLoading: model.busy(model.isLoadingEvents),
            isInteractionLimitedWhileLoading: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.title_schedule),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions:
                  model.busy(model.settings) ? [] : _buildActionButtons(model),
            ),
            body: model.busy(model.settings)
                ? const SizedBox()
                : displaySchedule(model)),
      );

  Widget displaySchedule(ScheduleViewModel model) {
    final calendar_view.EventController eventController =
        calendar_view.EventController();

    if (model.calendarFormat == CalendarTimeFormat.month) {
      return MonthCalendar(model: model, eventController: eventController, monthViewKey: monthViewKey);
    }
    if (model.calendarFormat == CalendarTimeFormat.week) {
      return WeekCalendar(model: model, eventController: eventController, weekViewKey: weekViewKey);
    }
    return DayCalendar(dayViewKey: dayViewKey);
  }

  List<Widget> _buildActionButtons(ScheduleViewModel model) => [
        IconButton(
          icon: const Icon(Icons.ios_share),
          onPressed: () {
            final translations = AppIntl.of(context)!;
            showDialog(
              context: context,
              builder: (_) =>
                  CalendarSelectionWidget(translations: translations),
            );
          },
        ),
        if ((model.settings[PreferencesFlag.scheduleShowTodayBtn] as bool))
          IconButton(
              icon: const Icon(Icons.today_outlined),
              onPressed: () => setState(() {
                    model.selectToday();
                    _analyticsService.logEvent(tag, "Select today clicked");
                    if (model.calendarFormat == CalendarTimeFormat.day &&
                        !(model.settings[PreferencesFlag.scheduleListView]
                            as bool)) {
                      dayViewKey.currentState?.animateToDate(DateTime.now());
                    } else if (model.calendarFormat ==
                        CalendarTimeFormat.week) {
                      weekViewKey.currentState?.animateToWeek(DateTime.now());
                    } else if (model.calendarFormat ==
                        CalendarTimeFormat.month) {
                      monthViewKey.currentState?.animateToMonth(
                          DateTime(DateTime.now().year, DateTime.now().month));
                    }
                  })),
        IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const ScheduleSettings());
              model.loadSettings();
            })
      ];
}
