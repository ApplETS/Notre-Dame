// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
import 'package:notredame/ui/schedule/widgets/day_view_header.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
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
    if (!model.calendarViewSetting) {
      return DayCalendar(m: model, eventController: eventController, dayViewKey: dayViewKey);
    }

    return _buildListView(model, context, eventController);
  }

  Widget _buildListView(ScheduleViewModel model, BuildContext context,
      calendar_view.EventController eventController) {
    return Stack(children: [
      GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx.abs() > 5) {
            setState(() {
              final int numberOfDays =
                  details.velocity.pixelsPerSecond.dx.sign.toInt();
              final DateTime newFocusedDate =
                  model.daySelected.subtract(Duration(days: numberOfDays));
              model.handleViewChanged(newFocusedDate, eventController, []);
              HapticFeedback.lightImpact();
            });
          }
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DayViewHeader(m: model, eventController: eventController, dayViewKey: dayViewKey),
            const SizedBox(height: 8.0),
            const Divider(indent: 8.0, endIndent: 8.0, thickness: 1),
            const SizedBox(height: 6.0),
            _buildTitleForDate(model.daySelected, model),
            const SizedBox(height: 2.0),
            if (model.selectedDateEvents(model.daySelected).isEmpty &&
                !model.isBusy)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child:
                    Center(child: Text(AppIntl.of(context)!.schedule_no_event)),
              )
            else
              _buildEventList(model.selectedDateEvents(model.daySelected)),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ]);
  }

  Widget _buildTitleForDate(DateTime date, ScheduleViewModel model) => Center(
          child: Text(
        DateFormat.MMMMEEEEd(model.locale.toString()).format(date),
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
