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
      ),
      
      SessionEvent(
        label: 'Session End',
        date: session.endDate,
        icon: Icons.stop,
      ),

      SessionEvent(
        label: 'Courses End',
        date: session.endDateCourses,
        icon: Icons.school
      ),
            
      SessionEvent(
        label: 'Registration Opens',
        date: session.startDateRegistration,
        icon: Icons.app_registration
      ),

      SessionEvent(
        label: 'Registration Deadline',
        date: session.deadlineRegistration,
        icon: Icons.event_busy
      ),
      
      SessionEvent(
        label: 'Cancellation with Refund (Start)',
        date: session.startDateCancellationWithRefund,
        icon: Icons.money
      ),

      SessionEvent(
        label: 'Cancellation with Refund (Deadline)',
        date: session.deadlineCancellationWithRefund,
        icon: Icons.money_off
      ),

      SessionEvent(
        label: 'New Student Refund Deadline',
        date: session.deadlineCancellationWithRefundNewStudent,
        icon: Icons.person_add
      ),

      SessionEvent(
        label: 'ASEQ Cancellation Deadline',
        date: session.deadlineCancellationASEQ,
        icon: Icons.group
      ),
    ].where((event) => event.date != null).toList();
  }
}
