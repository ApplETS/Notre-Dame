// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/quick_links.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';

// VIEW
import 'package:notredame/ui/views/quick_links_view.dart';

// WIDGETS
import 'package:notredame/ui/widgets/web_link_card.dart';

import '../../helpers.dart';
import '../../mock/managers/quick_links_repository_mock.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/internal_info_service_mock.dart';
import '../../mock/services/navigation_service_mock.dart';

void main() {
  AppIntl intl;

  QuickLinkRepository quickLinkRepository;

  group('QuickLinksView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupInternalInfoServiceMock();
      setupNetworkingServiceMock();
      setupLaunchUrlServiceMock();
      quickLinkRepository = setupQuickLinkRepositoryMock();
      QuickLinkRepositoryMock.stubGetDefaultQuickLinks(
          quickLinkRepository as QuickLinkRepositoryMock,
          toReturn: quickLinks(intl));

      QuickLinkRepositoryMock.stubGetQuickLinkDataFromCacheException(
          quickLinkRepository as QuickLinkRepositoryMock);
    });

    tearDown(() {
      unregister<NavigationServiceMock>();
      unregister<AnalyticsServiceMock>();
      unregister<InternalInfoServiceMock>();
      unregister<NetworkingService>();
      unregister<LaunchUrlService>();
      unregister<QuickLinkRepository>();
    });

    group('UI - ', () {
      testWidgets('has X cards', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: QuickLinksView()),
            useScaffold: false));
        await tester.pumpAndSettle();

        expect(find.byType(WebLinkCard, skipOffstage: false),
            findsNWidgets(quickLinks(intl).length));
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
