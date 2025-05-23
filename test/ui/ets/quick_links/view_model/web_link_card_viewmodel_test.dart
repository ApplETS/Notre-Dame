// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/ets/quick_links/view_model/web_link_card_viewmodel.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../../data/mocks/services/navigation_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late NavigationServiceMock navigationServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;
  late LaunchUrlServiceMock launchUrlServiceMock;

  late WebLinkCardViewModel viewModel;

  final quickLink = QuickLink(id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');
  final securityQuickLink = QuickLink(id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'security');

  group('WebLinkCardViewModel - ', () {
    setUp(() async {
      navigationServiceMock = setupNavigationServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      launchUrlServiceMock = setupLaunchUrlServiceMock();
      setupSettingsRepositoryMock();

      setupLogger();

      viewModel = WebLinkCardViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsServiceMock);
      clearInteractions(launchUrlServiceMock);
      unregister<AnalyticsService>();
      unregister<SettingsRepository>();
    });

    group('onLinkClicked -', () {
      test('navigate to security', () async {
        await viewModel.onLinkClicked(securityQuickLink);

        verify(analyticsServiceMock.logEvent("QuickLink", "QuickLink clicked: test"));
        verify(navigationServiceMock.pushNamed(RouterPaths.security));
        verifyNoMoreInteractions(navigationServiceMock);
      });

      test('navigate to web view if launchInBrowser throw', () async {
        await viewModel.onLinkClicked(quickLink);

        verify(launchUrlServiceMock.launchInBrowser(quickLink.link));
        verifyNoMoreInteractions(navigationServiceMock);
      });
    });
  });
}
