// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';
import 'package:notredame/ui/dashboard/view_model/cards/schedule_card_viewmodel.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) =>
    ViewModelBuilder<ScheduleCardViewmodel>.reactive(
      viewModelBuilder: () => ScheduleCardViewmodel(intl: AppIntl.of(context)!),
      builder: (context, model, child) {
        String title = AppIntl.of(context)!.title_schedule;
        if (model.tomorrow) {
          title += AppIntl.of(context)!.card_schedule_tomorrow;
        }

        return TitledCard(
          title: title,
          child: Expanded(
            child: model.isBusy
                ? Skeletonizer(
                    effect: ShimmerEffect(
                      baseColor: context.theme.appColors.dashboardCard,
                      highlightColor: context.theme.appColors.backgroundAlt,
                    ),
                    enabled: true,
                    child: Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      color: context.theme.appColors.dashboardCard,
                    ),
                  )
                : DayCalendar(
                    listView: model.listView,
                    controller: ScheduleController(),
                    selectedDate: model.date,
                    backgroundColor: context.theme.appColors.dashboardCard,
                  ),
          ),
        );
      },
    );
}
