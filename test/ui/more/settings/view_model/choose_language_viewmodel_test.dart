// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/choose_language/view_model/choose_language_viewmodel.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/navigation_service_mock.dart';
import '../../../../helpers.dart';

late ChooseLanguageViewModel viewModel;

void main() {
  late NavigationServiceMock navigationServiceMock;
  late SettingsRepositoryMock settingsManagerMock;

  group("ChooseLanguageViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      navigationServiceMock = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = ChooseLanguageViewModel(intl: intl);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<SettingsRepository>();
    });

    group("changeLanguage - ", () {
      test('can set language english', () async {
        viewModel.changeLanguage(0);

        verify(settingsManagerMock.locale = AppIntl.supportedLocales.first);
        verify(navigationServiceMock.pop());
        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.startup));
      });

      test('can set language français', () async {
        viewModel.changeLanguage(1);

        verify(settingsManagerMock.locale = AppIntl.supportedLocales.last);
        verify(navigationServiceMock.pop());
        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.startup));
      });

      test('throws an error when index does not exist', () async {
        expect(
          () => viewModel.changeLanguage(-1),
          throwsException,
          reason: "No valid language for the index -1 passed in parameters",
        );
      });
    });

    group("prop language - ", () {
      test('returns the languages successfully', () async {
        final languages = viewModel.languages;

        expect(['English', 'Français'], languages);
      });
    });
  });
}
