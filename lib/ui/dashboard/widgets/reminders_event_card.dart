import 'package:flutter/material.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/view_model/event_filter_service.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import '../../core/themes/app_palette.dart';
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

  Widget _buildEventCategory(String title, List<SessionEvent> events, Color backgroundColor) {
    if (events.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...events.map((event) => EventItemWidget(event: event)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = showOnlyUpcoming 
        ? EventFilterService.getUpcomingEvents(sessionEvents)
        : EventFilterService.getAllEvents(sessionEvents);

    final groupedEvents = EventFilterService.groupEventsByCategory(events);

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
                      showOnlyUpcoming 
                          ? 'Upcoming Events'
                          : sessionEvents?.name ?? 'Session Events',
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
                padding: const EdgeInsets.fromLTRB(17, 15, 17, 20),
                child: Column(
                  children: [
                    _buildEventCategory(
                      'Session',
                      groupedEvents['session'] ?? [],
                      AppPalette.gradeGoodMax.withOpacity(0.1),
                    ),
                    
                    _buildEventCategory(
                      'Registration',
                      groupedEvents['registration'] ?? [],
                      Colors.blue.withOpacity(0.1),
                    ),
                    
                    _buildEventCategory(
                      'Cancellation',
                      groupedEvents['cancellation'] ?? [],
                      Colors.orange.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            )
          else if (!loading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  showOnlyUpcoming 
                      ? 'No upcoming events'
                      : AppIntl.of(context)!.session_without,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
