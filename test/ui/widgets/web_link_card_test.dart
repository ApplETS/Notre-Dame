import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';

import '../../helpers.dart';

final _quickLink = QuickLink(
    image: 'assets/images/ic_security_red.png', name: 'test', link: 'testlink');

void main() {
  NavigationService navigationService;
  group('WebLinkCard - ', () {
    setUp(() {
      navigationService = setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    testWidgets('has an icon and a title', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: WebLinkCard(_quickLink)));
      await tester.pumpAndSettle();

      final text = find.byType(Text);
      final image = find.byType(Image);

      expect(text, findsNWidgets(1));
      expect(_quickLink.name, 'test');
      expect(image, findsNWidgets(1));
    });
  });
}
