// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/profile_viewmodel.dart';

// MODEL
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';

import '../helpers.dart';

// MOCKS
import '../mock/managers/user_repository_mock.dart';

UserRepository userRepository;
SettingsManager settingsManager;
ProfileViewModel viewModel;

void main() {
  final Program program1 = Program(
      name: 'program1',
      code: '0000',
      average: '0.00',
      accumulatedCredits: '99',
      registeredCredits: '99',
      completedCourses: '99',
      failedCourses: '0',
      equivalentCourses: '0',
      status: 'Actif');
  final Program program2 = Program(
      name: 'program2',
      code: '0001',
      average: '0.00',
      accumulatedCredits: '99',
      registeredCredits: '99',
      completedCourses: '99',
      failedCourses: '0',
      equivalentCourses: '0',
      status: 'Actif');
  final Program program3 = Program(
      name: 'program3',
      code: '0002',
      average: '0.00',
      accumulatedCredits: '99',
      registeredCredits: '99',
      completedCourses: '99',
      failedCourses: '99',
      equivalentCourses: '99',
      status: 'Actif');

  final List<Program> programs = [program1, program2, program3];

  final ProfileStudent info = ProfileStudent(
      balance: '99.99',
      firstName: 'John',
      lastName: 'Doe',
      permanentCode: 'DOEJ00000000');

  group("ProfileViewModel - ", () {
    setUp(() {
      // Setting up mocks
      userRepository = setupUserRepositoryMock();

      viewModel = ProfileViewModel();
    });

    tearDown(() {
      unregister<UserRepository>();
    });

    group("futureToRun - ", () {
      test(
          "first load from cache then call SignetsAPI to get the latest events",
          () async {
        UserRepositoryMock.stubGetInfo(userRepository as UserRepositoryMock);
        UserRepositoryMock.stubGetPrograms(
            userRepository as UserRepositoryMock);

        expect(await viewModel.futureToRun(), []);

        verifyInOrder([
          userRepository.getInfo(fromCacheOnly: true),
          userRepository.getPrograms(fromCacheOnly: true),
          userRepository.getInfo(),
        ]);

        verifyNoMoreInteractions(userRepository);
      });

      test("Signets throw an error while trying to get new events", () async {
        UserRepositoryMock.stubGetInfo(userRepository as UserRepositoryMock,
            fromCacheOnly: true);
        UserRepositoryMock.stubGetInfoException(
            userRepository as UserRepositoryMock,
            fromCacheOnly: false);
        UserRepositoryMock.stubGetPrograms(userRepository as UserRepositoryMock,
            fromCacheOnly: true);
        UserRepositoryMock.stubGetProgramsException(
            userRepository as UserRepositoryMock,
            fromCacheOnly: false);

        expect(await viewModel.futureToRun(), [],
            reason: "Even if SignetsAPI fails we should receives a list.");

        verifyInOrder([
          userRepository.getInfo(fromCacheOnly: true),
          userRepository.getPrograms(fromCacheOnly: true),
          userRepository.getInfo(),
        ]);

        verifyNoMoreInteractions(userRepository);
      });
    });

    group("info - ", () {
      test("build the info", () async {
        UserRepositoryMock.stubProfileStudent(
            userRepository as UserRepositoryMock,
            toReturn: info);

        expect(viewModel.profileStudent, info);

        verify(userRepository.info).called(1);

        verifyNoMoreInteractions(userRepository);
      });
    });

    group("programs - ", () {
      test("build the list of programs", () async {
        UserRepositoryMock.stubPrograms(userRepository as UserRepositoryMock,
            toReturn: programs);

        expect(viewModel.programList, programs);

        verify(userRepository.programs).called(2);

        verifyNoMoreInteractions(userRepository);
      });
    });
  });
}
