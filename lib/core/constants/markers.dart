import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notredame/generated/l10n.dart';

final List<Marker> markers = [
  Marker(
    position: const LatLng(45.49511855948888, -73.56270170940309),
    markerId: MarkerId('security_building_A'),
    infoWindow: InfoWindow(title: AppIntl.current.security_station),
  ),
  Marker(
    position: const LatLng(45.495089693692194, -73.56374294991838),
    markerId: MarkerId('security_building_B'),
    infoWindow: InfoWindow(title: AppIntl.current.security_station),
  ),
  Marker(
    position: const LatLng(45.49391646843658, -73.5634878349083),
    markerId: MarkerId('security_building_D'),
    infoWindow: InfoWindow(title: AppIntl.current.security_station),
  ),
];
