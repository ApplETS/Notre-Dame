// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rive/rive.dart';

// Project imports:
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/presentation/rive_animation_service.dart';
import 'package:notredame/features/app/error/not_found/not_found_viewmodel.dart';
import '../helpers.dart';
import '../mock/services/analytics_service_mock.dart';
import '../mock/services/navigation_service_mock.dart';
import '../mock/services/rive_animation_service_mock.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late RiveAnimationServiceMock riveAnimationServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;

  late NotFoundViewModel viewModel;

  group('NotFoundViewModel - ', () {
    const String pageNotFoundPassed = "/test";
    const String riveFileName = 'dot_jumping';

    setUp(() async {
      navigationServiceMock = setupNavigationServiceMock();
      riveAnimationServiceMock = setupRiveAnimationServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      setupLogger();

      viewModel = NotFoundViewModel(pageName: pageNotFoundPassed);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<AnalyticsService>();
      unregister<RiveAnimationService>();
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

    group('artboard prop - ', () {
      test('get the rive artboard when empty', () async {
        final artboard = viewModel.artboard;

        expect(artboard, null);
      });

      test('get the rive artboard when there is an instance', () async {
        final expectedArtboard = Artboard();

        RiveAnimationServiceMock.stubLoadRiveFile(
            riveAnimationServiceMock, 'dot_jumping', expectedArtboard);

        await viewModel.loadRiveAnimation();
        final artboard = viewModel.artboard;

        expect(artboard, expectedArtboard);
      });
    });

    group('loadRiveAnimation - ', () {
      test('load the dot_jumping Rive animation successfuly', () async {
        await viewModel.loadRiveAnimation();

        verify(
            riveAnimationServiceMock.loadRiveFile(riveFileName: riveFileName));
      });

      test('load file Rive animation with error', () async {
        RiveAnimationServiceMock.stubLoadRiveFileException(
            riveAnimationServiceMock);

        await viewModel.loadRiveAnimation();

        verify(analyticsServiceMock.logError(
            NotFoundViewModel.tag,
            "An Error has occurred during rive animation $riveFileName loading.",
            RiveAnimationServiceMock.loadException,
            any));
      });
    });

    group('startRiveAnimation - ', () {
      test('start Rive animation with error', () async {
        final artboard = Artboard();

        RiveAnimationServiceMock.stubLoadRiveFile(
            riveAnimationServiceMock, 'dot_jumping', artboard);

        RiveAnimationServiceMock.stubAddControllerToAnimationException(
            riveAnimationServiceMock, artboard);

        await viewModel.loadRiveAnimation();
        viewModel.startRiveAnimation();

        verify(analyticsServiceMock.logError(
            NotFoundViewModel.tag,
            "An Error has occured during rive animation start.",
            RiveAnimationServiceMock.startException,
            any));
      });
    });
  });
}
