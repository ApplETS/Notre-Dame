// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/startup/view_model/startup_viewmodel.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/auth_service_mock.dart';
import '../../../data/mocks/services/navigation_service_mock.dart';
import '../../../data/mocks/services/networking_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late SettingsRepositoryMock settingsRepositoryMock;
  late NetworkingServiceMock networkingServiceMock;
  late AuthServiceMock authServiceMock;

  late StartUpViewModel viewModel;
  late AppIntl appIntl;

  group('StartupViewModel - ', () {
    setUp(() async {
      setupAnalyticsServiceMock();
      navigationServiceMock = setupNavigationServiceMock();
      settingsRepositoryMock = setupSettingsRepositoryMock();
      networkingServiceMock = setupNetworkingServiceMock();
      authServiceMock = setupAuthServiceMock();

      appIntl = await setupAppIntl();
      viewModel = StartUpViewModel(intl: appIntl);
    });

    tearDown(() {
      unregister<AuthService>();
      unregister<NetworkingService>();
      unregister<UserRepository>();
      unregister<SettingsRepository>();
      unregister<NavigationService>();
      unregister<AnalyticsService>();
    });

    group('handleStartUp - ', () {
      test('silent sign in successful', () async {
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        SettingsRepositoryMock.stubGetBool(settingsRepositoryMock, PreferencesFlag.languageChoice, toReturn: true);
        AuthServiceMock.stubCreatePublicClientApplication(authServiceMock);
        AuthServiceMock.stubAcquireTokenSilent(authServiceMock);

        await viewModel.handleStartUp();

        verify(authServiceMock.acquireTokenSilent()).called(1);
        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.dashboard));
        verify(settingsRepositoryMock.setBool(PreferencesFlag.isLoggedIn, true)).called(1);
      });

      test('silent sign in failed redirect to login', () async {
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        SettingsRepositoryMock.stubGetBool(settingsRepositoryMock, PreferencesFlag.languageChoice, toReturn: true);
        AuthServiceMock.stubCreatePublicClientApplication(authServiceMock);
        AuthServiceMock.stubAcquireTokenSilent(authServiceMock, success: false);
        AuthServiceMock.stubAcquireToken(authServiceMock, success: true);

        await viewModel.handleStartUp();

        verify(authServiceMock.acquireTokenSilent()).called(1);
        verify(authServiceMock.acquireToken()).called(1);
        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.dashboard));
        verify(settingsRepositoryMock.setBool(PreferencesFlag.isLoggedIn, true)).called(1);
      });

      test('navigates to chooseLanguage if language not chosen', () async {
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        SettingsRepositoryMock.stubGetBool(settingsRepositoryMock, PreferencesFlag.languageChoice, toReturn: null);

        await viewModel.handleStartUp();

        verify(navigationServiceMock.pushNamed(RouterPaths.chooseLanguage)).called(1);
      });

      test('throws exception if createPublicClientApplication fails', () async {
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        SettingsRepositoryMock.stubGetBool(settingsRepositoryMock, PreferencesFlag.languageChoice, toReturn: true);
        AuthServiceMock.stubCreatePublicClientApplication(authServiceMock, success: false);

        expect(() async => await viewModel.handleStartUp(), throwsException);
      });
    });
  });
}
