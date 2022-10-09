// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// WIDGETS
import 'package:notredame/ui/widgets/link_web_view.dart';

// OTHER
import '../../helpers.dart';

final _quickLink = QuickLink(
    image: const Icon(Icons.ac_unit),
    name: 'test',
    link: 'https://clubapplets.ca/');

void main() {
  group('LinkWebView - ', () {
    setUp(() {
      setupNetworkingServiceMock();
    });

    testWidgets('has an AppBar and a WebView', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: LinkWebView(_quickLink)));

      final appBar = find.byType(AppBar);
      final webview = find.byType(WebView);

      expect(appBar, findsNWidgets(1));
      expect(_quickLink.name, 'test');
      expect(webview, findsNWidgets(1));
    });
  });
}
