// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/error/internal_info_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card_viewmodel.dart';
import '../helpers.dart';
import '../mock/services/analytics_service_mock.dart';
import '../mock/services/internal_info_service_mock.dart';
import '../mock/services/launch_url_service_mock.dart';
import '../mock/services/navigation_service_mock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late NavigationServiceMock navigationServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;
  late InternalInfoServiceMock internalInfoServiceMock;
  late LaunchUrlServiceMock launchUrlServiceMock;

  late WebLinkCardViewModel viewModel;

  final quickLink = QuickLink(
      id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'testlink');
  final securityQuickLink = QuickLink(
      id: 1, image: const Icon(Icons.ac_unit), name: 'test', link: 'security');

  group('WebLinkCardViewModel - ', () {
    setUp(() async {
      navigationServiceMock = setupNavigationServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      internalInfoServiceMock = setupInternalInfoServiceMock();
      launchUrlServiceMock = setupLaunchUrlServiceMock();
      setupSettingsManagerMock();

      setupLogger();

      viewModel = WebLinkCardViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      clearInteractions(analyticsServiceMock);
      clearInteractions(launchUrlServiceMock);
      unregister<AnalyticsService>();
      unregister<InternalInfoService>();
      unregister<SettingsManager>();
    });

    group('onLinkClicked -', () {
      test('navigate to security', () async {
        await viewModel.onLinkClicked(securityQuickLink, Brightness.light);

        verify(analyticsServiceMock.logEvent(
            "QuickLink", "QuickLink clicked: test"));
        verify(navigationServiceMock.pushNamed(RouterPaths.security));
        verifyNoMoreInteractions(navigationServiceMock);
      });

      test('navigate to web view if launchInBrowser throw', () async {
        InternalInfoServiceMock.stubGetDeviceInfoForErrorReporting(
            internalInfoServiceMock);

        await viewModel.onLinkClicked(quickLink, Brightness.light);

        verify(launchUrlServiceMock.launchInBrowser(
            quickLink.link, Brightness.light));
        verifyNoMoreInteractions(navigationServiceMock);
      });
    });
  });
}
