// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/programs_credits.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/ui/student/profile/view_model/profile_viewmodel.dart';
import '../../../../data/mocks/repositories/user_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late UserRepositoryMock userRepositoryMock;

  late ProfileViewModel viewModel;

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();
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
      permanentCode: 'DOEJ00000000',
      universalCode: 'AA000000');

  group("ProfileViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      userRepositoryMock = setupUserRepositoryMock();
      setupAnalyticsServiceMock();

      viewModel = ProfileViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<UserRepository>();
    });

    group("futureToRun - ", () {
      test(
          "first load from cache then call SignetsAPI to get the latest events",
          () async {
        UserRepositoryMock.stubGetInfo(userRepositoryMock, toReturn: info);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock);

        expect(await viewModel.futureToRun(), []);

        verifyInOrder([
          userRepositoryMock.getInfo(fromCacheOnly: true),
          userRepositoryMock.getPrograms(fromCacheOnly: true),
          userRepositoryMock.getInfo(),
          userRepositoryMock.getPrograms()
        ]);

        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Signets throw an error while trying to get new events", () async {
        setupFlutterToastMock();
        UserRepositoryMock.stubGetInfo(userRepositoryMock,
            fromCacheOnly: true, toReturn: info);
        UserRepositoryMock.stubGetInfoException(userRepositoryMock,
            fromCacheOnly: false);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock,
            fromCacheOnly: true);
        UserRepositoryMock.stubGetProgramsException(userRepositoryMock,
            fromCacheOnly: false);

        expect(await viewModel.futureToRun(), [],
            reason: "Even if SignetsAPI fails we should receives a list.");

        verifyInOrder([
          userRepositoryMock.getInfo(fromCacheOnly: true),
          userRepositoryMock.getPrograms(fromCacheOnly: true),
          userRepositoryMock.getInfo(),
          userRepositoryMock.programs
        ]);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });

    group("info - ", () {
      test("build the info", () async {
        UserRepositoryMock.stubProfileStudent(userRepositoryMock,
            toReturn: info);

        expect(viewModel.profileStudent, info);

        verify(userRepositoryMock.info).called(1);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });

    group("programs - ", () {
      test("build the list of programs", () async {
        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: programs);

        expect(viewModel.programList, programs);

        verify(userRepositoryMock.programs).called(2);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });

    group("programProgression - ", () {
      test("calculates program progression correctly", () {
        // Create a list of programs for testing
        final List<Program> testPrograms = [
          Program(
            name: 'Program A',
            code: '7625', // Program code with matching entry in ProgramCredits
            average: '3.50',
            accumulatedCredits: '30',
            registeredCredits: '60',
            completedCourses: '10',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Actif',
          ),
          Program(
            name: 'Program B',
            code: '7694', // Program code with matching entry in ProgramCredits
            average: '3.20',
            accumulatedCredits: '45',
            registeredCredits: '90',
            completedCourses: '20',
            failedCourses: '5',
            equivalentCourses: '0',
            status: 'Actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock,
            toReturn: testPrograms);

        // Create an instance of ProgramCredits
        final ProgramCredits programCredits = ProgramCredits();

        // Calculate the program progression
        final int progression = viewModel.programProgression;

        // Calculate the expected progression based on the defined ProgramCredits
        final int expectedProgression =
            (45 / programCredits.programsCredits['7694']! * 100).round();

        // Verify that the calculated progression matches the expected value
        expect(progression, expectedProgression);
      });

      test("handles no matching program code", () {
        // Create a list of programs with no matching program code
        final List<Program> testPrograms = [
          Program(
            name: 'Program X',
            code:
                '9999', // Program code with no matching entry in ProgramCredits
            average: '3.00',
            accumulatedCredits: '20',
            registeredCredits: '40',
            completedCourses: '5',
            failedCourses: '2',
            equivalentCourses: '0',
            status: 'Actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock,
            toReturn: testPrograms);

        // Calculate the program progression
        final int progression = viewModel.programProgression;

        // The expected progression should be 0 when there is no matching program code
        expect(progression, 0.0);
      });
    });

    group('refresh -', () {
      test('Call SignetsAPI to get the user info and programs', () async {
        UserRepositoryMock.stubProfileStudent(userRepositoryMock,
            toReturn: info);
        UserRepositoryMock.stubGetInfo(userRepositoryMock, toReturn: info);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock);

        await viewModel.refresh();

        expect(viewModel.profileStudent, info);

        verifyInOrder([
          userRepositoryMock.getInfo(),
          userRepositoryMock.getPrograms(),
          userRepositoryMock.info,
        ]);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });
  });
}
