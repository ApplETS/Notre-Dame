// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/ui/views/emergency_view.dart';
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

        final webView = find.byType(WebViewWidget);
        expect(webView, findsOneWidget);

        final Finder phoneButton = find.byType(FloatingActionButton);
        expect(phoneButton, findsOneWidget);
      });
    });
  });
}
