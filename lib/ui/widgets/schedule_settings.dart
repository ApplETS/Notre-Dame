// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/schedule_settings_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class ScheduleSettings extends StatefulWidget {
  final bool showHandle;

  const ScheduleSettings({Key? key, this.showHandle = true}) : super(key: key);

  @override
  _ScheduleSettingsState createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  final Color selectedColor = AppTheme.etsLightRed.withOpacity(0.5);

  @override
  Widget build(BuildContext context) => ViewModelBuilder.reactive(
        viewModelBuilder: () => ScheduleSettingsViewModel(),
        builder: (context, model, child) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: Column(
            children: [
              if (widget.showHandle)
                Container(
                  decoration: BoxDecoration(
                      color: Utils.getColorByBrightness(
                          context,
                          AppTheme.lightThemeBackground,
                          AppTheme.darkThemeBackground),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      )),
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
                      padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
                      child: Text(AppIntl.of(context)!.schedule_settings_title,
                          style: Theme.of(context).textTheme.headline6)),
                ),
              ),
              Expanded(
                child: ListTileTheme(
                  selectedColor: Theme.of(context).textTheme.bodyText1!.color,
                  child: ListView(
                    key: const ValueKey("SettingsScrollingArea"),
                    children: _buildSettings(
                        context, model as ScheduleSettingsViewModel),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _buildSettings(
      BuildContext context, ScheduleSettingsViewModel model) {
    final list = _buildCalendarFormatSection(context, model);

    list.addAll(_buildShowTodayButtonSection(context, model));

    if (model.toggleCalendarView) {
      list.addAll(_buildStartingDaySection(context, model));
      list.addAll(_buildShowWeekSection(context, model));
    } else if (model.calendarFormat == CalendarFormat.week) {
      model.showWeekendDays = true;
      list.addAll(_buildShowWeekendDaySection(context, model));
    } else {
      list.addAll(_buildShowWeekendDaySection(context, model));
    }

    list.addAll(_buildToggleCalendarView(context, model));

    if (model.scheduleActivitiesByCourse.isNotEmpty) {
      list.addAll(_buildSelectCoursesActivitiesSection(context, model));
    }

    return list;
  }

  List<Widget> _buildSelectCoursesActivitiesSection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final tiles = [
      Padding(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 15.0, bottom: 2.0),
        child: Text(
          AppIntl.of(context)!.schedule_select_course_activity,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(endIndent: 50, thickness: 1.5),
    ];

    for (final courseActivitiesAcronym
        in model.scheduleActivitiesByCourse.keys) {
      tiles.add(Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
        child: Text(
          '${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseAcronym ?? AppIntl.of(context)!.grades_not_available} - ${model.scheduleActivitiesByCourse[courseActivitiesAcronym]?.first.courseTitle ?? AppIntl.of(context)!.grades_not_available}}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      tiles.add(ListTile(
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
          tiles.add(ListTile(
            selected:
                model.selectedScheduleActivity[course.courseAcronym] == course,
            selectedTileColor: selectedColor,
            onTap: () =>
                model.selectScheduleActivity(course.courseAcronym, course),
            title: Text(getActivityTitle(course.activityCode)),
          ));
        }
      }

      if (model.scheduleActivitiesByCourse.values.length > 1) {
        tiles.add(const Divider(endIndent: 50, thickness: 1.5));
      }
    }
    tiles.add(const Divider(thickness: 1));
    return tiles;
  }

  String getActivityTitle(String activityCode) {
    if (activityCode == ActivityCode.labGroupA) {
      return AppIntl.of(context)!.course_activity_group_a;
    } else if (activityCode == ActivityCode.labGroupB) {
      return AppIntl.of(context)!.course_activity_group_b;
    }

    return "";
  }

  Iterable<Widget> _buildShowWeekSection(
          BuildContext context, ScheduleSettingsViewModel model) =>
      [
        ListTile(
          trailing: Switch(
            value: model.showWeekEvents,
            onChanged: (value) => model.showWeekEvents = value,
            activeColor: AppTheme.etsLightRed,
          ),
          title: Text(
              AppIntl.of(context)!.schedule_settings_show_week_events_btn_pref),
        ),
        const Divider(thickness: 1)
      ];

  List<Widget> _buildShowWeekendDaySection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final list = [
      Padding(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 15.0, bottom: 2.0),
        child: Text(
          AppIntl.of(context)!.schedule_settings_show_weekend_day,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(endIndent: 50, thickness: 1.5),
    ];

    list.add(ListTile(
      selected: model.otherDayOfWeek == WeekDays.monday,
      selectedTileColor: selectedColor,
      onTap: () => setState(() => model.otherDayOfWeek = WeekDays.monday),
      title: Text(AppIntl.of(context)!.schedule_settings_show_weekend_day_none),
    ));

    for (final WeekDays day in model.otherDayPossible) {
      list.add(ListTile(
        selected: model.otherDayOfWeek == day,
        selectedTileColor: selectedColor,
        onTap: () => setState(() => model.otherDayOfWeek = day),
        title: Text(getTextForWeekDay(context, day)),
      ));
    }

    list.add(const Divider(thickness: 1));

    return list;
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
          title:
              Text(AppIntl.of(context)!.schedule_settings_show_today_btn_pref),
        ),
        const Divider(thickness: 1)
      ];

  List<Widget> _buildToggleCalendarView(
          BuildContext context, ScheduleSettingsViewModel model) =>
      [
        ListTile(
          trailing: Switch(
            value: model.toggleCalendarView,
            onChanged: (value) => model.toggleCalendarView = value,
            activeColor: AppTheme.etsLightRed,
          ),
          title: Text(AppIntl.of(context)!.schedule_settings_list_view),
        ),
        const Divider(thickness: 1)
      ];

  List<Widget> _buildCalendarFormatSection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final tiles = [
      Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 2.0),
        child: Text(
          AppIntl.of(context)!.schedule_settings_calendar_format_pref,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(endIndent: 50, thickness: 1.5)
    ];

    for (final CalendarFormat format in model.calendarFormatPossibles) {
      tiles.add(ListTile(
        selected: model.calendarFormat == format,
        selectedTileColor: selectedColor,
        onTap: () => setState(() => model.calendarFormat = format),
        title: Text(getTextForFormat(context, format)),
      ));
    }

    tiles.add(const Divider(thickness: 1));

    return tiles;
  }

  List<Widget> _buildStartingDaySection(
      BuildContext context, ScheduleSettingsViewModel model) {
    final list = [
      Padding(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 15.0, bottom: 2.0),
        child: Text(
          AppIntl.of(context)!.schedule_settings_starting_weekday_pref,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(endIndent: 50, thickness: 1.5),
    ];

    for (final StartingDayOfWeek day in model.startingDayPossible) {
      list.add(ListTile(
        selected: model.startingDayOfWeek == day,
        selectedTileColor: selectedColor,
        onTap: () => setState(() => model.startingDayOfWeek = day),
        title: Text(getTextForDay(context, day)),
      ));
    }

    list.add(const Divider(thickness: 1));

    return list;
  }

  String getTextForFormat(BuildContext context, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return AppIntl.of(context)!.schedule_settings_calendar_format_month;
      case CalendarFormat.week:
        return AppIntl.of(context)!.schedule_settings_calendar_format_week;
      case CalendarFormat.twoWeeks:
        return AppIntl.of(context)!.schedule_settings_calendar_format_2_weeks;
      default:
        return AppIntl.of(context)!.schedule_settings_calendar_format_month;
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
