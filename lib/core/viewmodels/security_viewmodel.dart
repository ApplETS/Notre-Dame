import 'package:google_maps_flutter/google_maps_flutter.dart';

Set<Marker> getMarkers(List<Marker> markersList) {
  final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  for (int i = 0; i < markersList.length; i++) {
    markers[markersList[i].markerId] = markersList[i];
  }
  return Set<Marker>.of(markers.values);
}
