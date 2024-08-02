// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/emergency_view.dart';
import '../../helpers.dart';

void main() {
  group('EmergencyView - ', () {
    setUp(() async {
      WebViewPlatform.instance = AndroidWebViewPlatform();
      setupNetworkingServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has call button and markdown view', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const EmergencyView(
                'testEmergency', 'assets/markdown/armed_person_en.txt')));
        await tester.pumpAndSettle();

        final markdown = find.byType(Markdown);
        expect(markdown, findsOneWidget);

        final Finder phoneButton = find.byType(FloatingActionButton);
        expect(phoneButton, findsOneWidget);
      });
    });
  });
}
