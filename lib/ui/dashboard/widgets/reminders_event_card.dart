import 'package:flutter/material.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/view_model/event_filter_service.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import '../widgets/event_item_widget.dart';

class RemindersEventCard extends StatelessWidget {
  final VoidCallback onDismissed;
  final bool loading;
  final Session? sessionEvents;
  final bool showOnlyUpcoming;

  const RemindersEventCard({
    super.key,
    required this.onDismissed,
    required this.loading,
    required this.sessionEvents,
    this.showOnlyUpcoming = true,
  });

  Widget _buildEventCategory(String title, List<SessionEvent> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...events.map((event) => EventItemWidget(event: event)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = showOnlyUpcoming
        ? EventFilterService.getUpcomingEvents(sessionEvents)
        : EventFilterService.getAllEvents(sessionEvents);

    if (showOnlyUpcoming && events.isEmpty && !loading) {
      return const SizedBox.shrink();
    }

    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) => onDismissed(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showOnlyUpcoming ? 'Upcoming events' : sessionEvents?.name ?? 'Session events',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading || events.isNotEmpty)
            Skeletonizer(
              enabled: loading,
              ignoreContainers: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 0, 17, 13),
                child: Column(
                  children: [
                    _buildEventCategory('Session', events)
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
