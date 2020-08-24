import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notredame/core/constants/emergency_procedures.dart';
import 'package:notredame/core/constants/markers.dart';
import 'package:notredame/core/models/emergency_procedure_model.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityViewModel extends BaseViewModel {
  List<Marker> markersList = markers;

  List<EmergencyProcedure> emergencyProcedureList = emergencyProcedures;

  Set<Marker> getMarkers(List<Marker> markersList) {
    final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

    for (int i = 0; i < markersList.length; i++) {
      markers[markersList[i].markerId] = markersList[i];
    }
    return Set<Marker>.of(markers.values);
  }

  Future<void> makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
