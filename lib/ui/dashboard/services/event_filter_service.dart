// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';

class EventFilterService {
  final AppIntl translations;
  const EventFilterService({required this.translations});

  List<SessionEvent> getUpcomingEvents(List<Session>? session) {
    if (session == null) return [];
    List<SessionEvent> allEvents = [];

    for (Session s in session) {
      List<SessionEvent> curSessionEvents = _convertSessionToEvents(s);
      for (var cur in curSessionEvents) {
        allEvents.add(cur);
      }
    }
    return allEvents.where((event) => event.isUpcoming).toList();
  }

  List<SessionEvent> getAllEvents(Session? session) {
    if (session == null) return [];
    return _convertSessionToEvents(session);
  }

  List<SessionEvent> _convertSessionToEvents(Session session) {
    return [
      SessionEvent(
        label: translations.events_reminder_session_start,
        date: session.startDate,
        icon: Icons.play_arrow,
      ),
      SessionEvent(
        label: translations.events_reminder_session_end,
        date: session.endDate,
        icon: Icons.stop,
      ),
      SessionEvent(
        label: translations.events_reminder_courses_end,
        date: session.endDateCourses,
        icon: Icons.school,
      ),
      SessionEvent(
        label: translations.events_reminder_start_registration,
        date: session.startDateRegistration,
        icon: Icons.app_registration,
      ),
      SessionEvent(
        label: translations.events_reminder_end_registration,
        date: session.deadlineRegistration,
        icon: Icons.event_busy,
      ),
      SessionEvent(
        label: translations.events_reminder_end_cancel_with_refund,
        date: session.startDateCancellationWithRefund,
        icon: Icons.money,
      ),
      SessionEvent(
        label: translations.events_reminder_end_cancel_with_refund,
        date: session.deadlineCancellationWithRefund,
        icon: Icons.money_off,
      ),
      SessionEvent(
        label: translations.events_reminder_end_new_student_cancel_with_refund,
        date: session.deadlineCancellationWithRefundNewStudent,
        icon: Icons.person_add,
      ),
      SessionEvent(
        label: translations.events_reminder_end_cancel_aseq,
        date: session.deadlineCancellationASEQ,
        icon: Icons.group,
      ),
    ].where((event) => event.date != null).toList();
  }
}
