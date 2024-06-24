// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/repository/quick_link_repository.dart';
import 'package:notredame/features/ets/quick-link/models/quick_links.dart';
import 'package:notredame/features/ets/quick-link/quick_links_view.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card.dart';
import '../../helpers.dart';
import '../../mock/managers/quick_links_repository_mock.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/internal_info_service_mock.dart';
import '../../mock/services/navigation_service_mock.dart';

void main() {
  late AppIntl intl;

  QuickLinkRepositoryMock quickLinkRepositoryMock;

  group('QuickLinksView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupInternalInfoServiceMock();
      setupNetworkingServiceMock();
      setupLaunchUrlServiceMock();
      quickLinkRepositoryMock = setupQuickLinkRepositoryMock();
      QuickLinkRepositoryMock.stubGetDefaultQuickLinks(quickLinkRepositoryMock,
          toReturn: quickLinks(intl));

      QuickLinkRepositoryMock.stubGetQuickLinkDataFromCacheException(
          quickLinkRepositoryMock);
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
          tester.view.physicalSize = const Size(800, 1410);

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
