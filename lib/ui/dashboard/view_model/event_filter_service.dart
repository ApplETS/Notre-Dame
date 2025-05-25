import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';

import 'package:flutter/material.dart';

class EventFilterService {
  static List<SessionEvent> getUpcomingEvents(Session? session) {
    if (session == null) return [];

    final allEvents = _convertSessionToEvents(session);
    return allEvents.where((event) => event.isUpcoming).toList();
  }

  static List<SessionEvent> getAllEvents(Session? session) {
    if (session == null) return [];
    return _convertSessionToEvents(session);
  }

  static List<SessionEvent> _convertSessionToEvents(Session session) {
    return [
      SessionEvent(
        label: 'Session Start',
        date: session.startDate,
        icon: Icons.play_arrow,
        category: EventCategory.session,
      ),
      SessionEvent(
        label: 'Session End',
        date: session.endDate,
        icon: Icons.stop,
        category: EventCategory.session,
      ),
      SessionEvent(
        label: 'Courses End',
        date: session.endDateCourses,
        icon: Icons.school,
        category: EventCategory.session,
      ),
      
      
      SessionEvent(
        label: 'Registration Opens',
        date: session.startDateRegistration,
        icon: Icons.app_registration,
        category: EventCategory.registration,
      ),
      SessionEvent(
        label: 'Registration Deadline',
        date: session.deadlineRegistration,
        icon: Icons.event_busy,
        category: EventCategory.registration,
      ),
      

      SessionEvent(
        label: 'Cancellation with Refund (Start)',
        date: session.startDateCancellationWithRefund,
        icon: Icons.money,
        category: EventCategory.cancellation,
      ),
      SessionEvent(
        label: 'Cancellation with Refund (Deadline)',
        date: session.deadlineCancellationWithRefund,
        icon: Icons.money_off,
        category: EventCategory.cancellation,
      ),
      SessionEvent(
        label: 'New Student Refund Deadline',
        date: session.deadlineCancellationWithRefundNewStudent,
        icon: Icons.person_add,
        category: EventCategory.cancellation,
      ),
      SessionEvent(
        label: 'ASEQ Cancellation Deadline',
        date: session.deadlineCancellationASEQ,
        icon: Icons.group,
        category: EventCategory.cancellation,
      ),
    ].where((event) => event.date != null).toList();
  }

  static Map<String, List<SessionEvent>> groupEventsByCategory(List<SessionEvent> events) {
    final Map<String, List<SessionEvent>> grouped = {};
    
    for (final event in events) {
      grouped.putIfAbsent(event.category.name, () => []).add(event);
    }
    
    return grouped;
  }
}

enum EventCategory {
  session,
  registration,
  cancellation
}
