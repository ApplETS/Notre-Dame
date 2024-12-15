// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/ui/startup/view_model/startup_viewmodel.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import '../../../helpers.dart';
import '../../more/settings/mocks/settings_manager_mock.dart';
import '../error/mocks/internal_info_service_mock.dart';
import '../integration/mocks/networking_service_mock.dart';
import '../navigation/mocks/navigation_service_mock.dart';
import '../repository/mocks/user_repository_mock.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late UserRepositoryMock userRepositoryMock;
  late SettingsManagerMock settingsManagerMock;
  late NetworkingServiceMock networkingServiceMock;
  late InternalInfoServiceMock internalInfoServiceMock;

  late StartUpViewModel viewModel;

  group('StartupViewModel - ', () {
    setUp(() async {
      setupAnalyticsServiceMock();
      navigationServiceMock = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      userRepositoryMock = setupUserRepositoryMock();
      networkingServiceMock = setupNetworkingServiceMock();
      internalInfoServiceMock = setupInternalInfoServiceMock();
      setupLogger();

      viewModel = StartUpViewModel();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
      unregister<SettingsRepository>();
      unregister<PreferencesService>();
    });

    group('handleStartUp - ', () {
      test('sign in successful', () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        InternalInfoServiceMock.stubGetPackageInfo(internalInfoServiceMock,
            version: "4.0.0");

        await viewModel.handleStartUp();

        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.dashboard));
      });

      test(
          'sign in failed redirect to login',
          () async {
        UserRepositoryMock.stubSilentAuthenticate(userRepositoryMock,
            toReturn: false);
        UserRepositoryMock.stubWasPreviouslyLoggedIn(userRepositoryMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);

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
    });
  });
}
