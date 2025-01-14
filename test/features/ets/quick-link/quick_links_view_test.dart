// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/repository/quick_link_repository.dart';
import 'package:notredame/features/ets/quick-link/models/quick_links.dart';
import 'package:notredame/features/ets/quick-link/quick_links_view.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card.dart';
import '../../../common/helpers.dart';
import '../../app/analytics/mocks/analytics_service_mock.dart';
import '../../app/error/mocks/internal_info_service_mock.dart';
import '../../app/navigation/mocks/navigation_service_mock.dart';
import '../../app/repository/mocks/quick_links_repository_mock.dart';

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
            child: QuickLinksView(),
            useScaffold: false));
        await tester.pumpAndSettle();

        expect(find.byType(WebLinkCard, skipOffstage: false),
            findsNWidgets(quickLinks(intl).length));
      });
    });
  });
}
