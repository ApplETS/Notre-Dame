// Project imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/services/event_filter_service.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/event_item_widget.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';

class RemindersEventCard extends StatelessWidget {
  final VoidCallback onDismissed;
  final bool loading;
  final Session? sessionEvents;

  const RemindersEventCard({
    super.key,
    required this.onDismissed,
    required this.loading,
    required this.sessionEvents,
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
              ...events.asMap().entries.map((entry) {
                int index = entry.key;
                SessionEvent event = entry.value;
                return Column(
                  children: [
                    EventItemWidget(event: event),
                    if (index < events.length - 1) const SizedBox(height: 5),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = EventFilterService.getUpcomingEvents(sessionEvents);

    if (events.isEmpty && !loading) {
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
                      'Upcoming events',
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
                  children: [_buildEventCategory('Session', events)],
                ),
              ),
            )
        ],
      ),
    );
  }
}
