// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/ui/more/faq/view_model/faq_viewmodel.dart';
import '../../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late LaunchUrlServiceMock launchUrlServiceMock;
  late FaqViewModel viewModel;

  group('FaqViewModel - ', () {
    setUp(() async {
      launchUrlServiceMock = setupLaunchUrlServiceMock();
      setupSettingsRepositoryMock();
      setupRemoteConfigServiceMock();

      viewModel = FaqViewModel();
    });

    tearDown(() {
      unregister<SettingsRepository>();
      unregister<LaunchUrlService>();
      unregister<RemoteConfigService>();
    });

    group('Webview - ', () {
      test('Calls launchInBrowser', () {
        viewModel.launchWebsite("https://clubapplets.ca/");

        verify(launchUrlServiceMock.launchInBrowser("https://clubapplets.ca/")).called(1);
      });
    });
  });
}
