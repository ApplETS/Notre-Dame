// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/launch_url_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/faq_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/services/launch_url_service_mock.dart';

void main() {
  LaunchUrlServiceMock launchUrlService;

  FaqViewModel viewModel;

  group('FaqViewModel - ', () {
    setUp(() async {
      launchUrlService = setupLaunchUrlServiceMock() as LaunchUrlServiceMock;
      setupSettingsManagerMock();

      viewModel = FaqViewModel();
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<LaunchUrlService>();
    });

    group('Emails - ', () {
      test('Has the right mailto', () {
        final str = viewModel.mailtoStr("email", "subject");

        expect(str, "mailto:email?subject=subject");
      });
    });

    group('Webview - ', () {
      test('Calls launchInBrowser', () {
        viewModel.launchWebsite("https://clubapplets.ca/", Brightness.light);

        verify(launchUrlService.launchInBrowser("https://clubapplets.ca/", Brightness.light)).called(1);
      });
    });
  });
}
