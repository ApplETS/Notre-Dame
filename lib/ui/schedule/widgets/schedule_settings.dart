// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/schedule_settings_viewmodel.dart';

class ScheduleSettings extends StatefulWidget {
  final ScheduleController controller;
  const ScheduleSettings({super.key, required this.controller});

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  final Color selectedColor = AppPalette.etsLightRed.withValues(alpha: .5);

  @override
  Widget build(BuildContext context) => ViewModelBuilder.reactive(
      viewModelBuilder: () =>
          ScheduleSettingsViewModel(controller: widget.controller),
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
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.appColors.modalTitle,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                              color: context.theme.appColors.modalHandle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: context.theme.appColors.modalTitle,
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
                    child: Card(
                      color: context.theme.scaffoldBackgroundColor,
                      margin: const EdgeInsets.all(0),
                      shape: const RoundedRectangleBorder(),
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        controller: scrollController,
                        key: const ValueKey("SettingsScrollingArea"),
                        children: _buildSettings(context, model),
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

      final chips = <Widget>[];

      chips.add(InputChip(
          label: Text(AppIntl.of(context)!.course_activity_group_both),
          selected:
              model.selectedScheduleActivity[courseActivitiesAcronym] == null,
          selectedColor: selectedColor,
          showCheckmark: false,
          onPressed: () =>
              model.selectScheduleActivity(courseActivitiesAcronym, null)));

      if (model.scheduleActivitiesByCourse[courseActivitiesAcronym] != null) {
        for (final course
            in model.scheduleActivitiesByCourse[courseActivitiesAcronym]!) {
          chips.add(InputChip(
            label: Text(getActivityTitle(course.activityCode)),
            selected:
                model.selectedScheduleActivity[course.courseAcronym] == course,
            selectedColor: selectedColor,
            showCheckmark: false,
            onPressed: () =>
                model.selectScheduleActivity(course.courseAcronym, course),
          ));
        }
      }

      cardContent.add(Wrap(
        spacing: 10,
        alignment: WrapAlignment.center,
        children: chips,
      ));
    }

    return Card(
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
            activeColor: AppPalette.etsLightRed,
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
          activeColor: AppPalette.etsLightRed,
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
}
