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
import 'package:notredame/utils/utils.dart';

class ScheduleSettings extends StatefulWidget {
  final bool showHandle;

  const ScheduleSettings({super.key, this.showHandle = true});

  @override
  _ScheduleSettingsState createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  final Color selectedColor = AppTheme.etsLightRed.withOpacity(0.5);

  @override
  Widget build(BuildContext context) => ViewModelBuilder.reactive(
      viewModelBuilder: () => ScheduleSettingsViewModel(),
      builder: (context, model, child) {
        if (model.isBusy) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.55, // 55% of screen height
            child: const Center(child: CircularProgressIndicator()),
          );
        } else {
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
        }
      });

  List<Widget> _buildSettings(
      BuildContext context, ScheduleSettingsViewModel model) {
    final list = _buildShowTodayButtonSection(context, model);

    list.add(_buildCalendarFormatSection(context, model));

    if (model.toggleCalendarView) {
      list.add(_buildStartingDaySection(context, model));
      list.add(_buildShowWeekSection(context, model));
    } else if (model.calendarFormat == CalendarFormat.week) {
      model.showWeekendDays = true;
      list.add(_buildShowWeekendDaySection(context, model));
    } else {
      list.add(_buildShowWeekendDaySection(context, model));
    }

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
          '${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseAcronym ?? AppIntl.of(context)!.grades_not_available} - ${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseTitle ?? AppIntl.of(context)!.grades_not_available}}',
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

  Widget _buildShowWeekSection(
          BuildContext context, ScheduleSettingsViewModel model) =>
      ListTile(
        trailing: Switch(
          value: model.showWeekEvents,
          onChanged: (value) => model.showWeekEvents = value,
          activeColor: AppTheme.etsLightRed,
        ),
        title: Text(
            style: Theme.of(context).textTheme.bodySmall,
            AppIntl.of(context)!.schedule_settings_show_week_events_btn_pref),
      );

  Widget _buildShowWeekendDaySection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final chips = <Widget>[];

    chips.add(InputChip(
      selected: model.otherDayOfWeek == WeekDays.monday,
      selectedColor: selectedColor,
      onPressed: () => setState(() => model.otherDayOfWeek = WeekDays.monday),
      label: Text(AppIntl.of(context)!.schedule_settings_show_weekend_day_none),
    ));

    for (final WeekDays day in model.otherDayPossible) {
      chips.add(InputChip(
        selected: model.otherDayOfWeek == day,
        selectedColor: selectedColor,
        onPressed: () => setState(() => model.otherDayOfWeek = day),
        label: Text(getTextForWeekDay(context, day)),
      ));
    }

    final chipsWrapper = Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: chips,
    );

    final cardContent = [
      Text(
        AppIntl.of(context)!.schedule_settings_show_weekend_day,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Divider(thickness: 0.5),
      chipsWrapper
    ];

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
              style: Theme.of(context).textTheme.bodySmall,
              AppIntl.of(context)!.schedule_settings_show_today_btn_pref),
        )
      ];

  Widget _buildToggleCalendarView(
          BuildContext context, ScheduleSettingsViewModel model) =>
      ListTile(
        trailing: Switch(
          value: model.toggleCalendarView,
          onChanged: (value) => model.toggleCalendarView = value,
          activeColor: AppTheme.etsLightRed,
        ),
        title: Text(
            style: Theme.of(context).textTheme.bodySmall,
            AppIntl.of(context)!.schedule_settings_list_view),
      );

  Widget _buildCalendarFormatSection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final chips = <Widget>[];
    final formatList = model.toggleCalendarView
        ? model.formatPossibleListView
        : model.formatPossibleCalendarView;
    for (final CalendarFormat format in formatList) {
      chips.add(InputChip(
          label: Text(getTextForFormat(context, format)),
          selected: model.calendarFormat == format,
          selectedColor: selectedColor,
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
      _buildToggleCalendarView(context, model),
      chipsWrapper
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

  Widget _buildStartingDaySection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final chips = <Widget>[];

    for (final StartingDayOfWeek day in model.startingDayPossible) {
      chips.add(InputChip(
        selected: model.startingDayOfWeek == day,
        selectedColor: selectedColor,
        onPressed: () => setState(() => model.startingDayOfWeek = day),
        label: Text(getTextForDay(context, day)),
      ));
    }

    final chipsWrapper = Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: chips,
    );

    final cardContent = [
      Text(
        AppIntl.of(context)!.schedule_settings_starting_weekday_pref,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Divider(thickness: 0.5),
      chipsWrapper
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

  String getTextForFormat(BuildContext context, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return AppIntl.of(context)!.schedule_settings_calendar_format_month;
      case CalendarFormat.week:
        return AppIntl.of(context)!.schedule_settings_calendar_format_week;
      case CalendarFormat.twoWeeks:
        return AppIntl.of(context)!.schedule_settings_calendar_format_2_weeks;
      case CalendarFormat.day:
        return AppIntl.of(context)!.schedule_settings_calendar_format_day;
      default:
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
