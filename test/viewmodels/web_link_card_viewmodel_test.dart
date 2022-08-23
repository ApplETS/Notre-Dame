// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/web_link_card_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/services/internal_info_service_mock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NavigationService navigationService;
  AnalyticsService analyticsService;
  InternalInfoService internalInfoService;

  WebLinkCardViewModel viewModel;

  final _quickLink = QuickLink(
      image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');
  final _securityQuickLink = QuickLink(
      image: const Icon(Icons.ac_unit), name: 'test', link: 'security');

  group('WebLinkCardViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      analyticsService = setupAnalyticsServiceMock();
      internalInfoService = setupInternalInfoServiceMock();

      setupLogger();

      viewModel = WebLinkCardViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsService);
      unregister<AnalyticsService>();
      unregister<InternalInfoService>();
    });

    group('onLinkClicked -', () {
      test('navigate to security', () async {
        await viewModel.onLinkClicked(_securityQuickLink);

        verify(
            analyticsService.logEvent("QuickLink", "QuickLink clicked: test"));
        verify(navigationService.pushNamed(RouterPaths.security));
        verifyNoMoreInteractions(navigationService);
      });

      test('navigate to web view if launchInBrowser throw', () async {
        InternalInfoServiceMock.stubGetDeviceInfoForErrorReporting(
            internalInfoService as InternalInfoServiceMock);

        await viewModel.onLinkClicked(_quickLink);

        verify(navigationService.pushNamed(RouterPaths.webView,
            arguments: _quickLink));
        verifyNoMoreInteractions(navigationService);
      });
    });
  });
}
