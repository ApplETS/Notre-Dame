import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/models/progress_bar_text_options.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/logic/session_progress_use_case.dart';
import 'package:notredame/locator.dart';

import '../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../data/mocks/repositories/settings_repository_mock.dart';
import '../helpers.dart';

void main() {
  final _controller = StreamController<List<Session>>.broadcast();

  late ListSessionsRepositoryMock listSessionsRepository;
  late SettingsRepositoryMock settingsRepository;
  late SessionProgressUseCase useCase;
  AppIntl intl;

  setUp(() async {
    listSessionsRepository = setupListSessionsRepositoryMock();
    settingsRepository = setupSettingsRepositoryMock();
    intl = await setupAppIntl();

    useCase = SessionProgressUseCase(intl);
  });

  tearDown(() {
    locator.reset();
    useCase.dispose();
  });

  group('SessionProgressUseCase', () {
    test('init() initializes correctly with default text style', () async {
      SettingsRepositoryMock.stubGetString(
        settingsRepository,
        PreferencesFlag.progressBarText,
        toReturn: ProgressBarText.daysElapsedWithTotalDays.toString(),
      );

      var streamEvents = 0;
      final stream = _controller.stream;
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: stream);
      final listener = stream.listen((data) =>  streamEvents++);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: _controller, sessions: []);
      

      await useCase.init();

      verify(settingsRepository.getString(PreferencesFlag.progressBarText)).called(1);
      verify(listSessionsRepository.getSessions()).called(1);
      expect(streamEvents, 1);
      listener.cancel();
    });

    // test('changeProgressBarText() cycles through text styles', () async {
    //   when(settingsRepository.setString(any, any)).thenAnswer((_) async => {});

    //   useCase.changeProgressBarText();
    //   expect(useCase.stream, emits(isA<SessionProgress>()));

    //   verify(settingsRepository.setString(
    //     PreferencesFlag.progressBarText,
    //     ProgressBarText.percentage.toString(),
    //   )).called(1);
    // });

    // test('_getSessionProgressPercentage() returns correct percentage', () {
    //   final session = Session(
    //     daysCompleted: 10,
    //     totalDays: 20,
    //   );
    //   when(listSessionsRepository.getActiveSession()).thenReturn(session);

    //   final percentage = useCase._getSessionProgressPercentage();

    //   expect(percentage, 0.5);
    // });

    // test('_getProgressBarText() returns correct text for daysElapsedWithTotalDays', () {
    //   final session = Session(
    //     daysCompleted: 10,
    //     totalDays: 20,
    //   );
    //   when(listSessionsRepository.getActiveSession()).thenReturn(session);

    //   final text = useCase._getProgressBarText();

    //   expect(text, intl.progress_bar_message(10, 20));
    // });

    // test('fetch() calls getSessions with forceUpdate', () async {
    //   when(listSessionsRepository.getSessions(forceUpdate: true))
    //       .thenAnswer((_) async => []);

    //   await useCase.fetch(forceUpdate: true);

    //   verify(listSessionsRepository.getSessions(forceUpdate: true)).called(1);
    // });

    // test('dispose() closes the stream and cancels subscription', () {
    //   useCase.dispose();

    //   expect(() => useCase.stream.listen((_) {}), throwsA(isA<StateError>()));
    // });
  });
}