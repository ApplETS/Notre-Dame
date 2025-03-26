// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/quick_links.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/ets/quick_links/widgets/quick_links_view.dart';
import 'package:notredame/ui/ets/quick_links/widgets/web_link_card.dart';
import '../../../../data/mocks/repositories/quick_links_repository_mock.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../data/mocks/services/internal_info_service_mock.dart';
import '../../../../data/mocks/services/navigation_service_mock.dart';
import '../../../../helpers.dart';

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
      QuickLinkRepositoryMock.stubGetDefaultQuickLinks(quickLinkRepositoryMock, toReturn: quickLinks(intl));

      QuickLinkRepositoryMock.stubGetQuickLinkDataFromCacheException(quickLinkRepositoryMock);
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
        await tester.pumpWidget(localizedWidget(child: QuickLinksView(), useScaffold: false));
        await tester.pumpAndSettle();

        expect(find.byType(WebLinkCard, skipOffstage: false), findsNWidgets(quickLinks(intl).length));
      });
    });
  });
}
