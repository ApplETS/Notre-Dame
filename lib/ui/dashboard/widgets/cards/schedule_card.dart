// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/view_model/cards/schedule_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/widget_component.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    String title = AppIntl.of(context)!.title_schedule;

    return ViewModelBuilder<ScheduleCardViewmodel>.reactive(
      viewModelBuilder: () => ScheduleCardViewmodel(intl: AppIntl.of(context)!),
      builder: (context, model, child) {
        if (model.tomorrow) {
          title += AppIntl.of(context)!.card_schedule_tomorrow;
        }

        return WidgetComponent(
          title: title,
          child: Expanded(
            child: DayCalendar(
              listView: false,
              controller: ScheduleController(),
              selectedDate: model.date,
              backgroundColor: context.theme.appColors.dashboardCard,
            ),
          ),
        );
      },
    );
  }
}
