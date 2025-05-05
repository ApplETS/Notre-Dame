// Flutter imports:
import 'package:flutter/material.dart';

class ActionItem {
  final String title;
  final String description;
  final ActionType type;
  final String link;
  final IconData iconName;
  final Color iconColor;
  final Color circleColor;

  ActionItem({
    required this.title,
    required this.description,
    required this.type,
    required this.link,
    required this.iconName,
    required this.iconColor,
    required this.circleColor,
  });
}

enum ActionType {
  webview,
  email,
}
