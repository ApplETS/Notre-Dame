import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/ui/widgets/quick_links.dart';

import '../../helpers.dart';

QuickLinks _quickLinks;

void main() {
  group('QuickLinks - ', () {
    setUp(() {
      _quickLinks = setupQuickLinksMock();
    });

    tearDown(() {
      unregister<QuickLinks>();
    });

    testWidgets('has an icon and a title', (WidgetTester tester) async {
      await tester
          .pumpWidget(localizedWidget(child: QuickLinksWidget(_quickLinks)));
      await tester.pumpAndSettle();

      final text = find.byType(Text);
      final image = find.byType(Image);

      expect(text, findsNWidgets(1));
      expect(_quickLinks.name, 'test');
      expect(image, findsNWidgets(1));
    });
  });
}
