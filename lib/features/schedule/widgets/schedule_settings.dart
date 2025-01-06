// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/features/schedule/schedule_settings_viewmodel.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/calendar_utils.dart';
import 'package:notredame/utils/utils.dart';

class ScheduleSettings extends StatefulWidget {
  final bool showHandle;

  const ScheduleSettings({super.key, this.showHandle = true});

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  final Color selectedColor = AppTheme.etsLightRed.withValues(alpha: .5);

  @override
  Widget build(BuildContext context) => ViewModelBuilder.reactive(
      viewModelBuilder: () => ScheduleSettingsViewModel(),
      builder: (context, model, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: DraggableScrollableSheet(
              maxChildSize: 0.85,
              minChildSize: 0.5,
              initialChildSize: 0.55,
              expand: false,
              snap: true,
              snapSizes: const [
                0.55,
                0.85,
              ],
              builder: (context, ScrollController scrollController) {
                return Column(children: [
                  if (widget.showHandle)
                    Container(
                      decoration: BoxDecoration(
                        color: Utils.getColorByBrightness(
                            context,
                            AppTheme.lightThemeBackground,
                            AppTheme.darkThemeBackground),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Utils.getColorByBrightness(
                          context,
                          AppTheme.lightThemeBackground,
                          AppTheme.darkThemeBackground),
                    ),
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                              AppIntl.of(context)!.schedule_settings_title,
                              style: Theme.of(context).textTheme.titleLarge)),
                    ),
                  ),
                  Expanded(
                    child: ListTileTheme(
                      selectedColor:
                          Theme.of(context).textTheme.bodyLarge!.color,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                        color: Colors.transparent,
                        child: ListView(
                          controller: scrollController,
                          key: const ValueKey("SettingsScrollingArea"),
                          children: _buildSettings(context, model),
                        ),
                      ),
                    ),
                  )
                ]);
              }),
        );
      });

  List<Widget> _buildSettings(
      BuildContext context, ScheduleSettingsViewModel model) {
    final list = _buildShowTodayButtonSection(context, model);

    list.add(_buildCalendarFormatSection(context, model));

    if (model.scheduleActivitiesByCourse.isNotEmpty) {
      list.add(_buildSelectCoursesActivitiesSection(context, model));
    }

    return list;
  }

  Widget _buildSelectCoursesActivitiesSection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final cardContent = <Widget>[
      Text(
        AppIntl.of(context)!.schedule_select_course_activity,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Divider(thickness: 0.5)
    ];

    for (final courseActivitiesAcronym
        in model.scheduleActivitiesByCourse.keys) {
      cardContent.add(Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
        child: Text(
          '${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseAcronym ?? AppIntl.of(context)!.grades_not_available} - ${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseTitle ?? AppIntl.of(context)!.grades_not_available}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      cardContent.add(ListTile(
        selected:
            model.selectedScheduleActivity[courseActivitiesAcronym] == null,
        selectedTileColor: selectedColor,
        onTap: () =>
            model.selectScheduleActivity(courseActivitiesAcronym, null),
        title: Text(AppIntl.of(context)!.course_activity_group_both),
      ));

      if (model.scheduleActivitiesByCourse[courseActivitiesAcronym] != null) {
        for (final course
            in model.scheduleActivitiesByCourse[courseActivitiesAcronym]!) {
          cardContent.add(ListTile(
            selected:
                model.selectedScheduleActivity[course.courseAcronym] == course,
            selectedTileColor: selectedColor,
            onTap: () =>
                model.selectScheduleActivity(course.courseAcronym, course),
            title: Text(getActivityTitle(course.activityCode)),
          ));
        }
      }
    }

    return Card(
        elevation: 4,
        color: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightThemeBackground
            : AppTheme.darkThemeBackground,
        child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Column(
              children: cardContent,
            )));
  }

  String getActivityTitle(String activityCode) {
    if (activityCode == ActivityCode.labGroupA) {
      return AppIntl.of(context)!.course_activity_group_a;
    } else if (activityCode == ActivityCode.labGroupB) {
      return AppIntl.of(context)!.course_activity_group_b;
    }

    return "";
  }

  List<Widget> _buildShowTodayButtonSection(
          BuildContext context, ScheduleSettingsViewModel model) =>
      [
        ListTile(
          trailing: Switch(
            value: model.showTodayBtn,
            onChanged: (value) => model.showTodayBtn = value,
            activeColor: AppTheme.etsLightRed,
          ),
          title: Text(
              style: Theme.of(context).textTheme.bodyMedium,
              AppIntl.of(context)!.schedule_settings_show_today_btn_pref),
        )
      ];

  Widget _buildToggleCalendarView(
          BuildContext context, ScheduleSettingsViewModel model) =>
      ListTile(
        trailing: Switch(
          value: model.toggleCalendarView,
          onChanged: (value) => {
            model.toggleCalendarView = value,
          },
          activeColor: AppTheme.etsLightRed,
        ),
        title: Text(
            style: Theme.of(context).textTheme.bodyMedium,
            AppIntl.of(context)!.schedule_settings_list_view),
      );

  Widget _buildCalendarFormatSection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final chips = <Widget>[];

    for (final CalendarTimeFormat format in CalendarTimeFormat.values) {
      chips.add(InputChip(
          label: Text(getTextForFormat(context, format)),
          selected: model.calendarFormat == format,
          selectedColor: selectedColor,
          showCheckmark: false,
          onPressed: () => setState(() => model.calendarFormat = format)));
    }

    final chipsWrapper = Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: chips,
    );

    final cardContent = <Widget>[
      Text(
        AppIntl.of(context)!.schedule_settings_calendar_format_pref,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Divider(thickness: 0.5),
      chipsWrapper,
      if (model.calendarFormat == CalendarTimeFormat.day)
        _buildToggleCalendarView(context, model)
    ];

    return Card(
        elevation: 4,
        color: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightThemeBackground
            : AppTheme.darkThemeBackground,
        child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Column(children: cardContent)));
  }

  String getTextForFormat(BuildContext context, CalendarTimeFormat format) {
    switch (format) {
      case CalendarTimeFormat.month:
        return AppIntl.of(context)!.schedule_settings_calendar_format_month;
      case CalendarTimeFormat.week:
        return AppIntl.of(context)!.schedule_settings_calendar_format_week;
      case CalendarTimeFormat.day:
        return AppIntl.of(context)!.schedule_settings_calendar_format_day;
    }
  }

  String getTextForDay(BuildContext context, StartingDayOfWeek day) {
    switch (day) {
      case StartingDayOfWeek.sunday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_sunday;
      case StartingDayOfWeek.saturday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_saturday;
      case StartingDayOfWeek.monday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_monday;
      default:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_monday;
    }
  }

  String getTextForWeekDay(BuildContext context, WeekDays day) {
    switch (day) {
      case WeekDays.sunday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_sunday;
      case WeekDays.saturday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_saturday;
      case WeekDays.monday:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_monday;
      default:
        return AppIntl.of(context)!.schedule_settings_starting_weekday_monday;
    }
  }
}
