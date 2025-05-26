import 'package:flutter/material.dart';

class SessionEvent {
  final String label;
  final DateTime? date;
  final IconData icon;

  SessionEvent({
    required this.label,
    required this.date,
    required this.icon
  });

  bool get isUpcoming {
    if (date == null) return false;
    final now = DateTime.now();
    final difference = date!.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }
}
