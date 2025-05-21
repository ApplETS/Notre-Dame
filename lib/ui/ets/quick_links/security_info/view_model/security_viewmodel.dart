// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/emergency_procedure.dart';
import 'package:notredame/data/models/emergency_procedures.dart';
import 'package:notredame/domain/constants/markers.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class SecurityViewModel extends BaseViewModel {
  GoogleMapController? controller;
  String? mapStyle;

  final List<EmergencyProcedure> emergencyProcedureList;

  final List<Marker> markersList;

  SecurityViewModel({required AppIntl intl})
      : emergencyProcedureList = emergencyProcedures(intl),
        markersList = markers(intl);

  /// Used to get all security buildings to show in Google Maps
  Set<Marker> getSecurityMarkersForMaps(List<Marker> markersList) {
    final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    for (int i = 0; i < markersList.length; i++) {
      markers[markersList[i].markerId] = markersList[i];
    }
    return Set<Marker>.of(markers.values);
  }

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
