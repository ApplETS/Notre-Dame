// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<Marker> markers(AppIntl intl) => [
      Marker(
        position: const LatLng(45.49511855948888, -73.56270170940309),
        markerId: const MarkerId('security_building_A'),
        infoWindow: InfoWindow(title: intl.security_station),
      ),
      Marker(
        position: const LatLng(45.495089693692194, -73.56374294991838),
        markerId: const MarkerId('security_building_B'),
        infoWindow: InfoWindow(title: intl.security_station),
      ),
      Marker(
        position: const LatLng(45.49391646843658, -73.5634878349083),
        markerId: const MarkerId('security_building_D'),
        infoWindow: InfoWindow(title: intl.security_station),
      ),
    ];
