import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notredame/core/constants/emergency_procedures.dart';
import 'package:notredame/core/constants/markers.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/core/viewmodels/security_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';

import 'emergency_view.dart';

class SecurityView extends StatefulWidget {
  @override
  _SecurityViewState createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  static const CameraPosition _etsLocation = CameraPosition(
      target: LatLng(45.49449875, -73.56246144109338), zoom: 17.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppIntl.of(context).ets_security_title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: _etsLocation,
                zoomControlsEnabled: false,
                markers: getMarkers(markers),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppIntl.of(context).security_reach_security,
                style:
                    const TextStyle(color: AppTheme.etsLightRed, fontSize: 24),
              ),
            ),
            Card(
              child: InkWell(
                splashColor: Colors.red.withAlpha(50),
                onTap: () => makePhoneCall(
                    'tel:${AppIntl.of(context).security_emergency_number}'),
                child: ListTile(
                  leading: const Icon(Icons.phone, size: 30),
                  title: Text(AppIntl.of(context).security_emergency_call),
                  subtitle: Text(AppIntl.of(context).security_emergency_number),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, size: 30),
                title: Text(AppIntl.of(context).security_emergency_intern_call),
                subtitle:
                    Text(AppIntl.of(context).security_emergency_intern_number),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppIntl.of(context).security_emergency_procedures,
                style:
                    const TextStyle(color: AppTheme.etsLightRed, fontSize: 24),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  emergencyProcedures.length,
                  (index) => FlatButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmergencyView(
                                emergencyProcedures[index].title,
                                emergencyProcedures[index].detail))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            emergencyProcedures[index].title,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
