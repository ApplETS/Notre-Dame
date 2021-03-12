// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:rive/rive.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/rive_animation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

// OTHER
import 'package:notredame/core/constants/router_paths.dart';
import '../mock/services/rive_animation_service_mock.dart';
import '../helpers.dart';

void main() {
  NavigationService navigationService;
  RiveAnimationService riveAnimationService;
  AnalyticsService analyticsService;

  NotFoundViewModel viewModel;

  group('NotFoundViewModel - ', () {
    const String _pageNotFoundPassed = "/test";
    const String riveFileName = 'dot_jumping';

    setUp(() async {
      navigationService = setupNavigationServiceMock();
      riveAnimationService = setupRiveAnimationServiceMock();
      analyticsService = setupAnalyticsServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel(_pageNotFoundPassed);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<AnalyticsService>();
      unregister<RiveAnimationService>();
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

    group('artboard prop - ', () {
      test('get the rive artboard when empty', () async {
        final artboard = viewModel.artboard;

        expect(artboard, null);
      });

      test('get the rive artboard when there is an instance', () async {
        final expectedArtboard = Artboard();

        RiveAnimationServiceMock.stubLoadRiveFile(
            riveAnimationService as RiveAnimationServiceMock,
            'dot_jumping',
            expectedArtboard);

        await viewModel.loadRiveAnimation();
        final artboard = viewModel.artboard;

        expect(artboard, expectedArtboard);
      });
    });

    group('loadRiveAnimation - ', () {
      test('load the dot_jumping Rive animation successfuly', () async {
        await viewModel.loadRiveAnimation();

        verify(riveAnimationService.loadRiveFile(riveFileName: riveFileName));
      });

      test('load file Rive animation with error', () async {
        RiveAnimationServiceMock.stubLoadRiveFileException(
            riveAnimationService as RiveAnimationServiceMock);

        await viewModel.loadRiveAnimation();

        verify(analyticsService.logError(NotFoundViewModel.tag,
            "An Error has occured during rive animation $riveFileName loading."));
      });
    });

    group('startRiveAnimation - ', () {
      test('start Rive animation with error', () async {
        final artboard = Artboard();

        RiveAnimationServiceMock.stubLoadRiveFile(
            riveAnimationService as RiveAnimationServiceMock,
            'dot_jumping',
            artboard);

        RiveAnimationServiceMock.stubAddControllerToAnimationException(
            riveAnimationService as RiveAnimationServiceMock, artboard);

        await viewModel.loadRiveAnimation();
        viewModel.startRiveAnimation();

        verify(analyticsService.logError(NotFoundViewModel.tag,
            "An Error has occured during rive animation start."));
      });
    });
  });
}
