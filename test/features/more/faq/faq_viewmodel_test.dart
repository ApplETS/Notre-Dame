// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/features/more/faq/faq_viewmodel.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../../common/helpers.dart';
import '../../app/integration/mocks/launch_url_service_mock.dart';

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

    group('Webview - ', () {
      test('Calls launchInBrowser', () {
        viewModel.launchWebsite("https://clubapplets.ca/");

        verify(launchUrlServiceMock.launchInBrowser("https://clubapplets.ca/"))
            .called(1);
      });
    });
  });
}
