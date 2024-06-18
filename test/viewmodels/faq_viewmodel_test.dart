// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/more/faq/faq_viewmodel.dart';
import '../helpers.dart';
import '../mock/services/launch_url_service_mock.dart';

void main() {
  late LaunchUrlServiceMock launchUrlServiceMock;

  late FaqViewModel viewModel;

  group('FaqViewModel - ', () {
    setUp(() async {
      launchUrlServiceMock = setupLaunchUrlServiceMock();
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

        verify(launchUrlServiceMock.launchInBrowser(
                "https://clubapplets.ca/", Brightness.light))
            .called(1);
      });
    });
  });
}
