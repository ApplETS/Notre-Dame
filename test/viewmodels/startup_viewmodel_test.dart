// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

void main() {
  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;
  SettingsManager settingsManager;

  StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      settingsManager = setupSettingsManagerMock();
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;

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

        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });
      
      test('sign in failed redirect to login if Discovery already been completed', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);

        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.welcome, toReturn: 'true');
            
        await viewModel.handleStartUp();

        verify(navigationService.pushNamed(RouterPaths.login));
      });

      test('sign in failed redirect to Choose Language page if Discovery has not been completed', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);

        await viewModel.handleStartUp();
        
        verify(navigationService.pushNamed(RouterPaths.chooseLanguage));
        verify(settingsManager.setString(PreferencesFlag.welcome, 'true'));
      });
    });
  });
}
