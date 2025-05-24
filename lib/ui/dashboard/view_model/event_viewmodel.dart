import 'package:flutter/material.dart';
import 'package:notredame/ui/dashboard/view_model/event_filter_service.dart';

class SessionEvent {
  final String label;
  final DateTime? date;
  final IconData icon;
  final EventCategory category;

  SessionEvent({
    required this.label,
    required this.date,
    required this.icon,
    required this.category,
  });

  bool get isUpcoming {
    if (date == null) return false;
    final now = DateTime.now();
    final difference = date!.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  bool get isOverdue {
    if (date == null) return false;
    return date!.isBefore(DateTime.now());
  }
}
