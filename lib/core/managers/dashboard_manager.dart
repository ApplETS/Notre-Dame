// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardManager with ChangeNotifier {
  bool _showAboutUsCard = true;

  bool get showAboutUsCard => _showAboutUsCard;

  // ignore: avoid_positional_boolean_parameters
  void setShowAboutUsCard(bool value) {
    _showAboutUsCard = value;
    notifyListeners();
  }
}
