// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/ui/views/emergency_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers.dart';

void main() {
  group('EmergencyView - ', () {
    setUp(() async {});

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has call button and webview', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const EmergencyView(
                'testEmergency', 'assets/html/armed_person_detail_en.html')));
        await tester.pumpAndSettle();

        final webView = find.byType(WebView);
        expect(webView, findsOneWidget);

        final Finder phoneButton = find.byType(FloatingActionButton);
        expect(phoneButton, findsOneWidget);
      });
    });
  });
}
