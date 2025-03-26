// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/ui/more/faq/view_model/faq_viewmodel.dart';
import '../../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../../helpers.dart';

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

        verify(launchUrlServiceMock.launchInBrowser("https://clubapplets.ca/")).called(1);
      });

      test('ETS password assistance web page (en) returns "200 OK"', () async {
        final url = Uri.parse("https://partage.etsmtl.ca/fs/en.html");
        final http.Response response = await http.get(url);

        expect(response.statusCode, 200);
      });

      test('ETS password assistance web page (fr) returns "200 OK"', () async {
        final url = Uri.parse("https://partage.etsmtl.ca/fs/fr.html");
        final http.Response response = await http.get(url);

        expect(response.statusCode, 200);
      });
    });
  });
}
