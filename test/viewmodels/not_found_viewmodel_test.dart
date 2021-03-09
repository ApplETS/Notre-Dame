// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

// OTHER
import 'package:notredame/core/constants/router_paths.dart';
import '../helpers.dart';

void main() {
  NavigationService navigationService;

  NotFoundViewModel viewModel;

  group('NotFoundViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel("/test");
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    group('navigateToDashboard - ', () {
      test('navigating back worked', () async {
        viewModel.navigateToDashboard();

        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });
    });
  });
}
