// Package imports:
import 'package:material_ui/material_ui.dart';
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
  /// Owned by the dashboard, so it is shared between layouts and refreshed with it.
  final ScheduleCardViewmodel model;

  const ScheduleCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    String title = AppIntl.of(context)!.title_schedule;

    return ViewModelBuilder<ScheduleCardViewmodel>.reactive(
      viewModelBuilder: () => model,
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      builder: (context, model, child) {
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
}
