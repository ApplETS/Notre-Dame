// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/emergency_procedures.dart';

// VIEW
import 'package:notredame/ui/views/security_view.dart';

import '../../helpers.dart';

void main() {
  AppIntl intl;

  group('SecurityView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
    });

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

        final Finder emergencyList =
            find.widgetWithIcon(Card, Icons.arrow_forward_ios);
        expect(emergencyList, findsNWidgets(emergencyProcedures(intl).length));
      });
    });
  });
}
