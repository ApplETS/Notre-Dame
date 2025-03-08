// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/core/ui/calendar_selector.dart';
import 'package:notredame/ui/schedule/view_model/schedule_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/calendars/calendar_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import 'package:notredame/ui/schedule/widgets/calendars/week_calendar.dart';
import 'package:notredame/ui/schedule/widgets/schedule_settings.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  static const String tag = "ScheduleView";

  CalendarController controller = CalendarController();

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ScheduleViewModel>.reactive(
        viewModelBuilder: () => ScheduleViewModel(),
        onViewModelReady: (model) {
          if (model.settings.isEmpty) {
            model.loadSettings();
          }
        },
        builder: (context, model, child) => BaseScaffold(
            isLoading: model.isBusy,
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
    if (model.calendarFormat == CalendarTimeFormat.month) {
      return MonthCalendar(controller: controller);
    }
    if (model.calendarFormat == CalendarTimeFormat.week) {
      return WeekCalendar(controller: controller);
    }
    return DayCalendar(
      listView: model.calendarViewSetting,
      controller: controller,
    );
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
              onPressed: () {
                controller.returnToToday();
                _analyticsService.logEvent(tag, "Select today clicked");
              }),
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
