import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// FLUTTER / DART / THIRD-PARTIES
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

// CONSTANTS
import 'package:notredame/core/constants/emergency_procedures.dart';
import 'package:notredame/core/constants/markers.dart';

// MODEL
import 'package:notredame/core/models/emergency_procedure.dart';

class SecurityViewModel extends BaseViewModel {
  List<Marker> markersList = markers;
  GoogleMapController controller;
  List<EmergencyProcedure> emergencyProcedureList = emergencyProcedures;

  /// Used to get all security buildings to show in Google Maps
  Set<Marker> getSecurityMarkersForMaps(List<Marker> markersList) {
    final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    for (int i = 0; i < markersList.length; i++) {
      markers[markersList[i].markerId] = markersList[i];
    }
    return Set<Marker>.of(markers.values);
  }

  /// Used to open the phone application with the phone number
  Future<void> openPhoneApp(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Used to load a Json file
  Future<String> getJsonFile(String path) async {
    return rootBundle.loadString(path);
  }

  /// Used to change the color of the map based on the brightness
  void changeMapMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      getJsonFile("assets/dark_map_style.json").then(setMapStyle);
    } else {
      getJsonFile("assets/normal_map_style.json").then(setMapStyle);
    }
  }

  /// Used to set the color of the map
  void setMapStyle(String mapStyle) {
    controller.setMapStyle(mapStyle);
  }
}
