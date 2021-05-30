// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/networking_service_mock.dart';

void main() {
  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;
  SettingsManager settingsManager;
  NetworkingServiceMock networkingService;

  StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      settingsManager = setupSettingsManagerMock();
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;

      setupLogger();

      viewModel = StartUpViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
      unregister<SettingsManager>();
    });

    group('handleStartUp - ', () {
      test('sign in successful', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });

      test(
          'sign in failed redirect to login if Discovery already been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);

        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.discovery,
            toReturn: 'true');

        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.languageChoice,
            toReturn: 'true');

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.login));
      });

      test(
          'sign in failed redirect to Choose Language page if Discovery has not been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.chooseLanguage));
        verify(
            settingsManager.setString(PreferencesFlag.languageChoice, 'true'));
      });
    });
  });
}
