// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/error/internal_info_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card.dart';
import '../../helpers.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/launch_url_service_mock.dart';

final _quickLink = QuickLink(
    id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');

void main() {
  late AnalyticsServiceMock analyticsServiceMock;
  late LaunchUrlServiceMock launchUrlServiceMock;

  group('WebLinkCard - ', () {
    setUp(() {
      analyticsServiceMock = setupAnalyticsServiceMock();
      launchUrlServiceMock = setupLaunchUrlServiceMock();
      setupInternalInfoServiceMock();
      setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsServiceMock);
      clearInteractions(launchUrlServiceMock);
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
