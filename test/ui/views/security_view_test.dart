import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notredame/core/models/emergency_procedure_model.dart';
import 'package:notredame/ui/views/security_view.dart';

import '../../helpers.dart';

EmergencyProcedure _emergencyProcedures;

void main() {
  group('SecurityView - ', () {
    setUp(() async {
      _emergencyProcedures = setupEmergencyProceduresMock();
    });

    tearDown(() {
      unregister<EmergencyProcedure>();
    });

    group('UI - ', () {
      testWidgets('has maps view and emergency procedures',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: SecurityView()));
        await tester.pumpAndSettle();

        final gMaps = find.byType(GoogleMap);
        expect(gMaps, findsOneWidget);

        final Finder phoneButton = find.widgetWithText(Card, 'Emergency call');
        expect(phoneButton, findsOneWidget);

        //final Finder emergencyButton =
        //   find.widgetWithText(FlatButton, 'testEmergencyFlatButton');
        //expect(emergencyButton, findsOneWidget);
      });
    });
  });
}
