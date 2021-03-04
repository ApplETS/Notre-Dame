// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notredame/core/constants/emergency_procedures.dart';
import 'package:notredame/ui/views/security_view.dart';

import '../../helpers.dart';

void main() {
  group('SecurityView - ', () {
    setUp(() async {});

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has maps view and emergency procedures',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: SecurityView()));
        await tester.pumpAndSettle();

        final gMaps = find.byType(GoogleMap);
        expect(gMaps, findsOneWidget);

        final Finder emergencyProceduresList = find.text('Bomb threat');
        expect(emergencyProceduresList, findsOneWidget);

        final Finder phoneButton = find.widgetWithText(Card, 'Emergency call');
        expect(phoneButton, findsOneWidget);

        final Finder emergencyList = find.byType(TextButton);
        expect(emergencyList, findsNWidgets(emergencyProcedures.length));
      });
    });
  });
}
