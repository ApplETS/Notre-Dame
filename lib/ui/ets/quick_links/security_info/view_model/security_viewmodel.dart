// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/emergency_procedure.dart';
import 'package:notredame/data/models/emergency_procedures.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class SecurityViewModel extends BaseViewModel {
  String? mapStyle;

  final List<EmergencyProcedure> emergencyProcedureList;

  SecurityViewModel({required AppIntl intl}) : emergencyProcedureList = emergencyProcedures(intl);

  /// Used to load a Json file
  Future<String> getJsonFile(String path) async {
    return rootBundle.loadString(path);
  }

  /// Used to change the color of the map based on the brightness
  Future changeMapMode(BuildContext context) async {
    if (context.theme.brightness == Brightness.dark) {
      mapStyle = await getJsonFile("assets/dark_map_style.json");
    } else {
      mapStyle = await getJsonFile("assets/normal_map_style.json");
    }
    notifyListeners();
  }
}
