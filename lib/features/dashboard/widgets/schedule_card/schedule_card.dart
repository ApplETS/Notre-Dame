// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/dashboard/widgets/schedule_card/schedule_card_viewmodel.dart';
import 'package:notredame/utils/locator.dart';

class ScheduleCard extends StatelessWidget {
  final PreferencesFlag flag;
  final VoidCallback dismissCard;
  final NavigationService navigationService = locator<NavigationService>();

  ScheduleCard(this.flag, {
    required this.dismissCard,
    required super.key,
  });

  @override
  Widget build(BuildContext context) => ViewModelBuilder<ScheduleCardViewmodel>.reactive(
      viewModelBuilder: () => ScheduleCardViewmodel(),
      builder: (context, model, child) {
        final title = model.todayDateEvents.isEmpty && model.tomorrowDateEvents.isNotEmpty
            ? AppIntl.of(context)!.title_schedule + AppIntl.of(context)!.card_schedule_tomorrow
            : AppIntl.of(context)!.title_schedule;
        final events = model.todayDateEvents.isEmpty ? model.tomorrowDateEvents : model.todayDateEvents;
        return DismissibleCard(
          isBusy: model.busy(model.todayDateEvents) ||
              model.busy(model.tomorrowDateEvents),
          onDismissed: (DismissDirection direction) => dismissCard(),
          key: UniqueKey(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                  child: GestureDetector(
                    onTap: () =>
                        navigationService
                            .pushNamedAndRemoveUntil(RouterPaths.schedule),
                    child: Text(title,
                                style: Theme.of(context).textTheme.titleLarge),
                  ),
                )),
              if (events.isEmpty) _buildNoEventText(context)
              else _buildEventList(events)
            ]),
          ),
        );
      });

  SizedBox _buildNoEventText(BuildContext context) => SizedBox(
    height: 100,
    child: Center(
        child: Text(AppIntl.of(context)!.schedule_no_event)));

  Widget _buildEventList(List<dynamic> events) =>
    ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
}
