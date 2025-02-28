// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/domain/broadcast_icon_type.dart';

class BroadcastMessage {
  final String message;
  final String title;
  final Color color;
  final String url;
  final BroadcastIconType type;

  BroadcastMessage({
    required this.message,
    required this.title,
    required this.color,
    required this.url,
    required this.type,
  });
}
