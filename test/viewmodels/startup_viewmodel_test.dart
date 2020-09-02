// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/user_repository_mock.dart';

void main() {
  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;

  StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;

      viewModel = StartUpViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
    });

    group('handleStartUp - ', () {
      test('sign in successful', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });

      test('sign in failed', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.login));
      });
    });
  });
}
