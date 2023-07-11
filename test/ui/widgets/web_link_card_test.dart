import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/internal_info_service.dart';

// WIDGETS
import 'package:notredame/ui/widgets/web_link_card.dart';

import '../../helpers.dart';

final _quickLink = QuickLink(
    id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');

void main() {
  AnalyticsService analyticsService;

  group('WebLinkCard - ', () {
    setUp(() {
      analyticsService = setupAnalyticsServiceMock();
      setupInternalInfoServiceMock();
      setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsService);
      unregister<AnalyticsService>();
      unregister<InternalInfoService>();
    });

    testWidgets('has an icon and a title', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: WebLinkCard(_quickLink)));
      await tester.pumpAndSettle();

      final text = find.byType(Text);
      final icon1 = find.byType(Icon);

      expect(text, findsNWidgets(1));
      expect(_quickLink.name, 'test');
      expect(icon1, findsNWidgets(1));
    });
  });
}
