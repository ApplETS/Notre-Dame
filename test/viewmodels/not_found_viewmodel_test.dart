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
    const String _pageNotFoundPassed = "/test";
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel(_pageNotFoundPassed);
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

    group('notFoundPageName prop - ', () {
      test('get the page pass in parameter', () async {
        final notFoundName = viewModel.notFoundPageName;

        expect(_pageNotFoundPassed, notFoundName);
      });
    });
  });
}
