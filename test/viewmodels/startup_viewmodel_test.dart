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
import 'package:notredame/core/services/preferences_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/internal_info_service_mock.dart';
import '../mock/services/networking_service_mock.dart';
import '../mock/services/preferences_service_mock.dart';

void main() {
  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;
  SettingsManagerMock settingsManagerMock;
  PreferencesServiceMock preferencesServiceMock;
  NetworkingServiceMock networkingService;
  InternalInfoServiceMock internalInfoServiceMock;
  StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock() as SettingsManagerMock;
      preferencesServiceMock =
          setupPreferencesServiceMock() as PreferencesServiceMock;
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      internalInfoServiceMock =
          setupInternalInfoServiceMock() as InternalInfoServiceMock;

      setupLogger();

      viewModel = StartUpViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
      unregister<SettingsManager>();
      unregister<PreferencesService>();
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

      test('verify discovery flags are bool if version mismatch', () async {
        const String versionToSave = "4.1.0";
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: versionToSave);
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.appVersion);
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryDashboard,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoverySchedule,
            toReturn: 'false');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryGradeDetails,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryStudentProfile);
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryETS);

        await viewModel.handleStartUp();

        verify(preferencesServiceMock.getPreferencesFlag(any)).called(8);

        verifyInOrder([
          settingsManagerMock.getString(PreferencesFlag.appVersion),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryDashboard),
          settingsManagerMock.setBool(PreferencesFlag.discoveryDashboard, true),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoverySchedule),
          settingsManagerMock.setBool(PreferencesFlag.discoverySchedule, false),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryStudentGrade),
          settingsManagerMock.setBool(
              PreferencesFlag.discoveryStudentGrade, true),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryGradeDetails),
          settingsManagerMock.setBool(
              PreferencesFlag.discoveryGradeDetails, true),
          settingsManagerMock.setString(
              PreferencesFlag.appVersion, versionToSave)
        ]);
      });

      test('verify discovery flags are not changed for same version', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verifyNever(preferencesServiceMock.getPreferencesFlag(any));
        verifyNever(settingsManagerMock.setBool(any, any));
        verifyNever(
            settingsManagerMock.setString(PreferencesFlag.appVersion, "4.0.1"));
      });

      test('verify discovery flags are bool is trigger for no present version',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingService);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.appVersion);
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryDashboard,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoverySchedule,
            toReturn: 'false');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryGradeDetails,
            toReturn: 'true');
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryStudentProfile);
        PreferencesServiceMock.stubGetPreferencesFlag(
            preferencesServiceMock, PreferencesFlag.discoveryETS);

        await viewModel.handleStartUp();

        verify(preferencesServiceMock.getPreferencesFlag(any)).called(8);

        verifyInOrder([
          settingsManagerMock.getString(PreferencesFlag.appVersion),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryDashboard),
          settingsManagerMock.setBool(PreferencesFlag.discoveryDashboard, true),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoverySchedule),
          settingsManagerMock.setBool(PreferencesFlag.discoverySchedule, false),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryStudentGrade),
          settingsManagerMock.setBool(
              PreferencesFlag.discoveryStudentGrade, true),
          preferencesServiceMock
              .removePreferencesFlag(PreferencesFlag.discoveryGradeDetails),
          settingsManagerMock.setBool(
              PreferencesFlag.discoveryGradeDetails, true),
          settingsManagerMock.setString(PreferencesFlag.appVersion, "4.0.0")
        ]);
      });
    });
  });
}
