// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/quick_links.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';

// VIEW
import 'package:notredame/ui/views/quick_links_view.dart';

// WIDGETS
import 'package:notredame/ui/widgets/web_link_card.dart';

import '../../helpers.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/internal_info_service_mock.dart';
import '../../mock/services/navigation_service_mock.dart';

void main() {
  AppIntl intl;

  group('QuickLinksView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupInternalInfoServiceMock();
      setupNetworkingServiceMock();
      setupLaunchUrlServiceMock();
    });

    tearDown(() {
      unregister<NavigationServiceMock>();
      unregister<AnalyticsServiceMock>();
      unregister<InternalInfoServiceMock>();
      unregister<NetworkingService>();
      unregister<LaunchUrlService>();
    });

    group('UI - ', () {
      testWidgets('has X cards', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: QuickLinksView()),
            useScaffold: false));
        await tester.pumpAndSettle();

        expect(
            find.byType(WebLinkCard), findsNWidgets(quickLinks(intl).length));
      });

      group("golden - ", () {
        testWidgets("default view", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: QuickLinksView()),
              useScaffold: false));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 500));

          await expectLater(find.byType(QuickLinksView),
              matchesGoldenFile(goldenFilePath("quicksLinksView_1")));
        });
      }, skip: !Platform.isLinux);
    });
  });
}
