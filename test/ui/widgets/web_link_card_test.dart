import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/models/quick_link_model.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';

import '../../helpers.dart';

QuickLink _quickLinks;

void main() {
  group('QuickLinks - ', () {
    setUp(() {
      _quickLinks = setupQuickLinksMock();
    });

    tearDown(() {
      unregister<QuickLink>();
    });

    testWidgets('has an icon and a title', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: WebLinkCard(_quickLinks)));
      await tester.pumpAndSettle();

      final text = find.byType(Text);
      final image = find.byType(Image);

      expect(text, findsNWidgets(1));
      expect(_quickLinks.name, 'test');
      expect(image, findsNWidgets(1));
    });
  });
}
