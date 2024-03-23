// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_semver/pub_semver.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/constants/update_code.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/siren_flutter_service.dart';
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/internal_info_service_mock.dart';
import '../mock/services/navigation_service_mock.dart';
import '../mock/services/networking_service_mock.dart';
import '../mock/services/preferences_service_mock.dart';
import '../mock/services/siren_flutter_service_mock.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late UserRepositoryMock userRepositoryMock;
  late SettingsManagerMock settingsManagerMock;
  late PreferencesServiceMock preferencesServiceMock;
  late NetworkingServiceMock networkingServiceMock;
  late InternalInfoServiceMock internalInfoServiceMock;
  late SirenFlutterServiceMock sirenFlutterServiceMock;

  late StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      setupAnalyticsServiceMock();
      navigationServiceMock = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      preferencesServiceMock = setupPreferencesServiceMock();
      userRepositoryMock = setupUserRepositoryMock();
      networkingServiceMock = setupNetworkingServiceMock();
      internalInfoServiceMock = setupInternalInfoServiceMock();
      sirenFlutterServiceMock = setupSirenFlutterServiceMock();
      setupLogger();

      viewModel = StartUpViewModel();

      SirenFlutterServiceMock.stubUpdateIsAvailable(sirenFlutterServiceMock);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
      unregister<SettingsManager>();
      unregister<PreferencesService>();
      unregister<SirenFlutterService>();
    });

    group('handleStartUp - ', () {
      test('sign in successful', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verify(navigationServiceMock.pushNamedAndRemoveUntil(
            RouterPaths.dashboard, RouterPaths.dashboard, UpdateCode.none));
      });

      test(
          'sign in failed redirect to login if Discovery already been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
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
          navigationServiceMock.pop(),
          navigationServiceMock.pushNamed(RouterPaths.login)
        ]);

        verifyNoMoreInteractions(navigationServiceMock);
      });

      test(
          'sign in failed redirect to Choose Language page if Discovery has not been completed',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.appVersion,
            toReturn: "4.0.0");

        await viewModel.handleStartUp();

        verifyInOrder([
          settingsManagerMock.getBool(PreferencesFlag.languageChoice),
          navigationServiceMock.pushNamed(RouterPaths.chooseLanguage),
          settingsManagerMock.setBool(PreferencesFlag.languageChoice, true)
        ]);

        verifyNoMoreInteractions(navigationServiceMock);
      });

      test('verify discovery flags are bool if version mismatch', () async {
        const String versionToSave = "4.1.0";
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
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
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
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
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
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

    group('checkUpdateStatus - ', () {
      test('should return UpdateCode.none if update is not available',
          () async {
        SirenFlutterServiceMock.stubUpdateIsAvailable(sirenFlutterServiceMock);

        final result = await viewModel.checkUpdateStatus();

        expect(result, UpdateCode.none);
      });

      test(
          "should return UpdateCode.ask if update is available and it's a minor or major changes",
          () async {
        SirenFlutterServiceMock.stubUpdateIsAvailable(sirenFlutterServiceMock,
            valueToReturn: true);
        SirenFlutterServiceMock.stubLocalVersion(sirenFlutterServiceMock,
            valueToReturn: Version(4, 0, 0));
        SirenFlutterServiceMock.stubStoreVersion(sirenFlutterServiceMock,
            valueToReturn: Version(4, 1, 0));

        var result = await viewModel.checkUpdateStatus();

        expect(result, UpdateCode.ask);

        SirenFlutterServiceMock.stubLocalVersion(sirenFlutterServiceMock,
            valueToReturn: Version(4, 0, 0));
        SirenFlutterServiceMock.stubStoreVersion(sirenFlutterServiceMock,
            valueToReturn: Version(5, 0, 0));

        result = await viewModel.checkUpdateStatus();

        expect(result, UpdateCode.ask);
      });

      test(
          "should return UpdateCode.force if update is available and it's a revision changes",
          () async {
        SirenFlutterServiceMock.stubUpdateIsAvailable(sirenFlutterServiceMock,
            valueToReturn: true);
        SirenFlutterServiceMock.stubLocalVersion(sirenFlutterServiceMock,
            valueToReturn: Version(4, 0, 0));
        SirenFlutterServiceMock.stubStoreVersion(sirenFlutterServiceMock,
            valueToReturn: Version(4, 0, 1));

        final result = await viewModel.checkUpdateStatus();

        expect(result, UpdateCode.force);
      });
    });
  });
}
