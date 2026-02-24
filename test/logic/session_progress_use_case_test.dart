import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/models/progress_bar_text_options.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/logic/session_progress_use_case.dart';
import 'package:notredame/locator.dart';

import '../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../data/mocks/repositories/settings_repository_mock.dart';
import '../helpers.dart';

void main() {
  late StreamController<List<Session>> controller;
  late ListSessionsRepositoryMock listSessionsRepository;
  late SettingsRepositoryMock settingsRepository;
  late SessionProgressUseCase useCase;
  late AppIntl intl;

  setUp(() async {
    controller = StreamController<List<Session>>.broadcast();
    listSessionsRepository = setupListSessionsRepositoryMock();
    settingsRepository = setupSettingsRepositoryMock();
    intl = await setupAppIntl();

    useCase = SessionProgressUseCase(intl);
  });

  tearDown(() {
    locator.reset();
    useCase.dispose();
    controller.close();
  });

  group('SessionProgressUseCase', () {
    test('init() initializes correctly with default text style', () async {
      SettingsRepositoryMock.stubGetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: ProgressBarText.daysElapsedWithTotalDays.toString(),
      );
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();

      verify(settingsRepository.getString(PreferencesFlag.progressBarText)).called(1);
      verify(listSessionsRepository.getSessions()).called(1);
    });

    test('changeProgressBarText() cycles through text styles', () async {
      SettingsRepositoryMock.stubSetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: true
      );
      SettingsRepositoryMock.stubGetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: ProgressBarText.daysElapsedWithTotalDays.toString(),
      );
      
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);
      
      await useCase.init();
      useCase.changeProgressBarText();

      verify(settingsRepository.setString(
        PreferencesFlag.progressBarText,
        ProgressBarText.percentage.toString(),
      )).called(1);
    });

    test('fetch() calls getSessions with forceUpdate', () async {
      SettingsRepositoryMock.stubGetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: ProgressBarText.daysElapsedWithTotalDays.toString(),
      );
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();
      await useCase.fetch(forceUpdate: true);

      verify(listSessionsRepository.getSessions(forceUpdate: true)).called(1);
    });

    test('dispose() closes the stream and cancels subscription', () async {
      SettingsRepositoryMock.stubGetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: ProgressBarText.daysElapsedWithTotalDays.toString(),
      );
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();
      useCase.dispose();

      // After dispose, listening to the stream should not emit any events
      var emittedEvents = 0;
      useCase.stream.listen((_) => emittedEvents++);
      
      expect(emittedEvents, 0);
    });
  });
}