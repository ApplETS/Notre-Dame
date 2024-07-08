// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/emergency_view.dart';
import '../../../../../common/helpers.dart';

void main() {
  group('EmergencyView - ', () {
    setUp(() async {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    });

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
