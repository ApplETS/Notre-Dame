// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import '../../helpers.dart';
import '../mocks/services/preferences_service_mock.dart';

void main() {
  late PreferencesServiceMock preferencesServiceMock;

  late SettingsRepository repository;

  group("SettingsRepository - ", () {
    setUp(() {
      preferencesServiceMock = setupPreferencesServiceMock();
      repository = SettingsRepository();
    });

    tearDown(() {
      unregister<PreferencesService>();
    });

    group("ThemeMode - ", () {
      test("set light/dark/system mode", () {
        repository.themeMode = ThemeMode.light;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.light.toString())).called(1);

        repository.themeMode = ThemeMode.dark;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.dark.toString())).called(1);

        repository.themeMode = ThemeMode.system;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.system.toString())).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("get", () {
        const flag = PreferencesFlag.theme;
        PreferencesServiceMock.stubGetString(preferencesServiceMock, flag, toReturn: ThemeMode.light.toString());

        ThemeMode result = repository.themeMode;

        expect(result, ThemeMode.light);

        verify(preferencesServiceMock.getString(flag)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });

    group("Locale - ", () {
      test("validate default behaviour", () {
        PreferencesServiceMock.stubGetString(preferencesServiceMock, PreferencesFlag.locale, toReturn: 'fr');

        repository.locale = Locale('fr');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr')).called(1);

        repository.locale;

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("set french/english", () {
        repository.locale = Locale('fr');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr')).called(1);

        repository.locale = Locale('en');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'en')).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("default locale isn't set", () {
        const flag = PreferencesFlag.locale;
        when(preferencesServiceMock.getString(flag)).thenAnswer((_) => null);

        expect(repository.locale, const Locale('fr'));

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });
  });
}
