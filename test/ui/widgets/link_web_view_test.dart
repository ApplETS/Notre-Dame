// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/ui/widgets/link_web_view.dart';
import '../../helpers.dart';

final _quickLink = QuickLink(
    id: 1,
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
