// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/ui/more/faq/view_model/faq_viewmodel.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
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
      unregister<SettingsRepository>();
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
