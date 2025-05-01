// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/not_found/view_model/not_found_viewmodel.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../data/mocks/services/navigation_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;

  late NotFoundViewModel viewModel;

  group('NotFoundViewModel - ', () {
    const String pageNotFoundPassed = "/test";

    setUp(() async {
      navigationServiceMock = setupNavigationServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel(pageName: pageNotFoundPassed);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<AnalyticsService>();
    });

    group('constructor - ', () {
      test('test that an analytics event is lauch', () async {
        const String pageTestCtor = "\testctor";
        NotFoundViewModel(pageName: pageTestCtor);

        verify(analyticsServiceMock.logEvent(
            NotFoundViewModel.tag, "An unknown page ($pageTestCtor) has been access from the app."));
      });
    });

    group('navigateToDashboard - ', () {
      test('navigating back worked', () async {
        viewModel.navigateToDashboard();

        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.root));
      });
    });

    group('notFoundPageName prop - ', () {
      test('get the page pass in parameter', () async {
        final notFoundName = viewModel.notFoundPageName;

        expect(pageNotFoundPassed, notFoundName);
      });
    });
  });
}
