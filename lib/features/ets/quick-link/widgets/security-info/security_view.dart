// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/emergency_view.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/security_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class SecurityView extends StatefulWidget {
  @override
  _SecurityViewState createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  static const CameraPosition _etsLocation = CameraPosition(
      target: LatLng(45.49449875, -73.56246144109338), zoom: 17.0);

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<SecurityViewModel>.reactive(
        viewModelBuilder: () => SecurityViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context)!.ets_security_title),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 250,
                  child: GoogleMap(
                      initialCameraPosition: _etsLocation,
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
                      }),
                ),
                joinSecurity(),
                emergencyProcedures(model),
              ],
            ),
          ),
        ),
      );

  Widget joinSecurity() => Padding(
    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppIntl.of(context)!.security_reach_security,
          style: const TextStyle(
              color: AppTheme.etsLightRed, fontSize: 24),
        ),
        Card(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            splashColor: Colors.red.withAlpha(50),
            onTap: () => Utils.launchURL(
                'tel:${AppIntl.of(context)!.security_emergency_number}',
                AppIntl.of(context)!)
                .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())));
            }),
            child: ListTile(
              leading: const Icon(Icons.phone, size: 30),
              title: Text(AppIntl.of(context)!.security_emergency_call),
              subtitle:
              Text(AppIntl.of(context)!.security_emergency_number),
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.phone, size: 30),
            title: Text(
                AppIntl.of(context)!.security_emergency_intern_call),
            subtitle: Text(
                AppIntl.of(context)!.security_emergency_intern_number),
          ),
        ),
      ],
    ),
  );

  Widget emergencyProcedures(SecurityViewModel model) => SingleChildScrollView(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 24.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppIntl.of(context)!.security_emergency_procedures,
          style: const TextStyle(
              color: AppTheme.etsLightRed, fontSize: 24),
        ),
        for (int i = 0; i < model.emergencyProcedureList.length; i++)
          Card(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              splashColor: Colors.red.withAlpha(50),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmergencyView(
                          model.emergencyProcedureList[i].title,
                          model.emergencyProcedureList[i].detail))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 16.0, left: 16.0),
                    child: Text(
                      model.emergencyProcedureList[i].title,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ),
      ]
    ),
  );
}
