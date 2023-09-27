// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/security_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/views/emergency_view.dart';

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
        viewModelBuilder: () => SecurityViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context).ets_security_title),
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
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer()),
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppIntl.of(context).security_reach_security,
                    style: const TextStyle(
                        color: AppTheme.etsLightRed, fontSize: 24),
                  ),
                ),
                Card(
                  child: InkWell(
                    splashColor: Colors.red.withAlpha(50),
                    onTap: () => Utils.launchURL(
                            'tel:${AppIntl.of(context).security_emergency_number}',
                            AppIntl.of(context))
                        .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    }),
                    child: ListTile(
                      leading: const Icon(Icons.phone, size: 30),
                      title: Text(AppIntl.of(context).security_emergency_call),
                      subtitle:
                          Text(AppIntl.of(context).security_emergency_number),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.phone, size: 30),
                    title: Text(
                        AppIntl.of(context).security_emergency_intern_call),
                    subtitle: Text(
                        AppIntl.of(context).security_emergency_intern_number),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppIntl.of(context).security_emergency_procedures,
                    style: const TextStyle(
                        color: AppTheme.etsLightRed, fontSize: 24),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      model.emergencyProcedureList.length,
                      (index) => Card(
                        child: InkWell(
                          splashColor: Colors.red.withAlpha(50),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EmergencyView(
                                      model.emergencyProcedureList[index].title,
                                      model.emergencyProcedureList[index]
                                          .detail))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0, bottom: 16.0, left: 16.0),
                                child: Text(
                                  model.emergencyProcedureList[index].title,
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
                ),
              ],
            ),
          ),
        ),
      );
}
