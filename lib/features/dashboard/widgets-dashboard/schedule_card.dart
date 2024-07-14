import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';

class ScheduleCard extends StatelessWidget {
  final DashboardViewModel model;
  final PreferencesFlag flag;
  final VoidCallback dismissCard;
  final NavigationService navigationService;

  const ScheduleCard({
    required this.model,
    required this.flag,
    required this.dismissCard,
    required this.navigationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var title = AppIntl.of(context)!.title_schedule;
    if (model.todayDateEvents.isEmpty && model.tomorrowDateEvents.isNotEmpty) {
      title = title + AppIntl.of(context)!.card_schedule_tomorrow;
    }
    return DismissibleCard(
      isBusy: model.busy(model.todayDateEvents) ||
          model.busy(model.tomorrowDateEvents),
      onDismissed: (DismissDirection direction) {
        dismissCard();
      },
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: GestureDetector(
                  onTap: () => navigationService
                      .pushNamedAndRemoveUntil(RouterPaths.schedule),
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              )),
          if (model.todayDateEvents.isEmpty)
            if (model.tomorrowDateEvents.isEmpty)
              SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(AppIntl.of(context)!.schedule_no_event)))
            else
              _buildEventList(model.tomorrowDateEvents)
          else
            _buildEventList(model.todayDateEvents)
        ]),
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
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
}
