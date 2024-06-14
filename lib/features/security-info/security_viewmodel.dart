// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/emergency_procedures.dart';
import 'package:notredame/constants/markers.dart';
import 'package:notredame/features/security-info/emergency_procedure.dart';

class SecurityViewModel extends BaseViewModel {
  GoogleMapController? controller;

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
  void changeMapMode(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      getJsonFile("assets/dark_map_style.json").then(setMapStyle);
    } else {
      getJsonFile("assets/normal_map_style.json").then(setMapStyle);
    }
  }

  /// Used to set the color of the map
  void setMapStyle(String mapStyle) {
    controller?.setMapStyle(mapStyle);
  }
}
