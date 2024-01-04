// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/viewmodels/web_link_card_viewmodel.dart';
import '../helpers.dart';
import '../mock/services/internal_info_service_mock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late NavigationService navigationService;
  late AnalyticsService analyticsService;
  late InternalInfoService internalInfoService;
  late LaunchUrlService launchUrlService;

  late WebLinkCardViewModel viewModel;

  final quickLink = QuickLink(
      id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');
  final securityQuickLink = QuickLink(
      id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'security');

  group('WebLinkCardViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      analyticsService = setupAnalyticsServiceMock();
      internalInfoService = setupInternalInfoServiceMock();
      launchUrlService = setupLaunchUrlServiceMock();
      setupSettingsManagerMock();

      setupLogger();

      viewModel = WebLinkCardViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsService);
      clearInteractions(launchUrlService);
      unregister<AnalyticsService>();
      unregister<InternalInfoService>();
      unregister<SettingsManager>();
    });

    group('onLinkClicked -', () {
      test('navigate to security', () async {
        await viewModel.onLinkClicked(securityQuickLink, Brightness.light);

        verify(
            analyticsService.logEvent("QuickLink", "QuickLink clicked: test"));
        verify(navigationService.pushNamed(RouterPaths.security));
        verifyNoMoreInteractions(navigationService);
      });

      test('navigate to web view if launchInBrowser throw', () async {
        InternalInfoServiceMock.stubGetDeviceInfoForErrorReporting(
            internalInfoService as InternalInfoServiceMock);

        await viewModel.onLinkClicked(quickLink, Brightness.light);

        verify(
            launchUrlService.launchInBrowser(quickLink.link, Brightness.light));
        verifyNoMoreInteractions(navigationService);
      });
    });
  });
}
