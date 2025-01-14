// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/error/not_found/not_found_viewmodel.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import '../../../../common/helpers.dart';
import '../../analytics/mocks/analytics_service_mock.dart';
import '../../navigation/mocks/navigation_service_mock.dart';

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

        verify(analyticsServiceMock.logEvent(NotFoundViewModel.tag,
            "An unknown page ($pageTestCtor) has been access from the app."));
      });
    });

    group('navigateToDashboard - ', () {
      test('navigating back worked', () async {
        viewModel.navigateToDashboard();

        verify(navigationServiceMock
            .pushNamedAndRemoveUntil(RouterPaths.dashboard));
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
