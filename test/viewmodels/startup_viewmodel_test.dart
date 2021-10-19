// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/cache_manager.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/internal_info_service_mock.dart';
import '../mock/services/networking_service_mock.dart';

void main() {
  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;
  SettingsManagerMock settingsManagerMock;
  NetworkingServiceMock networkingService;
  InternalInfoServiceMock internalInfoServiceMock;
  CacheManagerMock cacheManagerMock;
  StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock() as SettingsManagerMock;
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      internalInfoServiceMock =
          setupInternalInfoServiceMock() as InternalInfoServiceMock;
      cacheManagerMock = setupCacheManagerMock() as CacheManagerMock;

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
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verify(
            navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard));
      });

      test(
          'sign in failed redirect to login if Discovery already been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        SettingsManagerMock.stubGetBool(
            settingsManagerMock, PreferencesFlag.languageChoice,
            toReturn: true);

        await viewModel.handleStartUp();

        verifyInOrder([
          settingsManagerMock.getBool(PreferencesFlag.languageChoice),
          navigationService.pop(),
          navigationService.pushNamed(RouterPaths.login)
        ]);

        verifyNoMoreInteractions(navigationService);
      });

      test(
          'sign in failed redirect to Choose Language page if Discovery has not been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verifyInOrder([
          settingsManagerMock.getBool(PreferencesFlag.languageChoice),
          navigationService.pushNamed(RouterPaths.chooseLanguage),
          settingsManagerMock.setBool(PreferencesFlag.languageChoice, true)
        ]);

        verifyNoMoreInteractions(navigationService);
      });

      test('verify cache removal if version mismatch', () async {
        const String versionToSave = "4.0.0";
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: versionToSave);
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.1");
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.appVersion);

        SettingsManagerMock.stubGetBool(
            settingsManagerMock, PreferencesFlag.languageChoice,
            toReturn: true);

        await viewModel.handleStartUp();

        verifyInOrder([
          cacheManagerMock.empty(),
          settingsManagerMock.setString(
              PreferencesFlag.appVersion, versionToSave)
        ]);
      });

      test('verify cache removal has not trigger for same version', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verify(cacheManagerMock.empty()).called(0);
        verify(settingsManagerMock.setString(
                PreferencesFlag.appVersion, "4.0.1"))
            .called(0);
      });

      test('verify cache removal has trigger for no present version', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: null);

        await viewModel.handleStartUp();

        verify(cacheManagerMock.empty()).called(0);
        verify(settingsManagerMock.setString(
                PreferencesFlag.appVersion, "4.0.1"))
            .called(0);
      });
    });
  });
}
