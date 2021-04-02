// FLUTTER / DART / THIRD-PARTIES

import 'package:flutter/material.dart';

class DashboardManager with ChangeNotifier {
  bool _showAboutUsCard = true;

  bool get showAboutUsCard => _showAboutUsCard;

  // ignore: avoid_positional_boolean_parameters
  void setShowAboutUsCard(bool value) {
    _showAboutUsCard = value;
    notifyListeners();
  }
}
