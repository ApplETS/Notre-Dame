// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';
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
  
  final _quickLink = QuickLink(image: 'assets/images/ic_security_red.png', name: 'test', link: 'testlink');
    
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
        viewModel.onLinkClicked(_quickLink);

        verify(navigationService.pushNamed(RouterPaths.security));
      });

      test('navigate to web view if launchInBrowser throw', () async {
        InternalInfoServiceMock.stubGetDeviceInfoForErrorReporting(internalInfoService as InternalInfoServiceMock);

        await viewModel.onLinkClicked(_quickLink);

        verify(navigationService.pushNamed(RouterPaths.webView, arguments: _quickLink.link));
      });

    });

  });
}
