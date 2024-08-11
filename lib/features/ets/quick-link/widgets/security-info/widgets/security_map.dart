// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/security_viewmodel.dart';

Widget securityMap(BuildContext context, SecurityViewModel model) {
  const CameraPosition etsLocation = CameraPosition(
      target: LatLng(45.49449875, -73.56246144109338), zoom: 17.0);
  return SizedBox(
    height: 250,
    child: GoogleMap(
        initialCameraPosition: etsLocation,
        zoomControlsEnabled: false,
        markers:
            model.getSecurityMarkersForMaps(model.markersList),
        onMapCreated: (GoogleMapController controller) {
          model.controller = controller;
          model.changeMapMode(context);
        },
        gestureRecognizers: <Factory<
            OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer()),
        })
  );
}
