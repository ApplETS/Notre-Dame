// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

// OTHER
import '../helpers.dart';

void main() {
  NavigationService navigationService;

  NotFoundViewModel viewModel;

  group('NotFoundViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    group('handleStartUp - ', () {
      test('navigating back worked', () async {
        viewModel.navigateToDashboard();

        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });
    });
  });
}
