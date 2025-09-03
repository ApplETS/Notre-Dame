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
    status: 'Actif',
  );
  final Program program2 = Program(
    name: 'program2',
    code: '0001',
    average: '0.00',
    accumulatedCredits: '99',
    registeredCredits: '99',
    completedCourses: '99',
    failedCourses: '0',
    equivalentCourses: '0',
    status: 'Actif',
  );
  final Program program3 = Program(
    name: 'program3',
    code: '0002',
    average: '0.00',
    accumulatedCredits: '99',
    registeredCredits: '99',
    completedCourses: '99',
    failedCourses: '99',
    equivalentCourses: '99',
    status: 'Actif',
  );

  final List<Program> programs = [program1, program2, program3];

  final ProfileStudent info = ProfileStudent(
    balance: '99.99',
    firstName: 'John',
    lastName: 'Doe',
    permanentCode: 'DOEJ00000000',
    universalCode: 'AA000000',
  );

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
      test("first load from cache then call SignetsAPI to get the latest events", () async {
        UserRepositoryMock.stubGetInfo(userRepositoryMock, toReturn: info);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock);

        expect(await viewModel.futureToRun(), []);

        verifyInOrder([
          userRepositoryMock.getInfo(fromCacheOnly: true),
          userRepositoryMock.getPrograms(fromCacheOnly: true),
          userRepositoryMock.getInfo(),
          userRepositoryMock.getPrograms(),
        ]);

        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Signets throw an error while trying to get new events", () async {
        setupFlutterToastMock();
        UserRepositoryMock.stubGetInfo(userRepositoryMock, fromCacheOnly: true, toReturn: info);
        UserRepositoryMock.stubGetInfoException(userRepositoryMock, fromCacheOnly: false);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock, fromCacheOnly: true);
        UserRepositoryMock.stubGetProgramsException(userRepositoryMock, fromCacheOnly: false);

        expect(await viewModel.futureToRun(), [], reason: "Even if SignetsAPI fails we should receives a list.");

        verifyInOrder([
          userRepositoryMock.getInfo(fromCacheOnly: true),
          userRepositoryMock.getPrograms(fromCacheOnly: true),
          userRepositoryMock.getInfo(),
          userRepositoryMock.programs,
        ]);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });

    group("info - ", () {
      test("build the info", () async {
        UserRepositoryMock.stubProfileStudent(userRepositoryMock, toReturn: info);

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
        final List<Program> programsWithKnownCodes = [
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

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: programsWithKnownCodes);

        // Create an instance of ProgramCredits
        final ProgramCredits programCredits = ProgramCredits();

        // Calculate the program progression
        final int progression = viewModel.programProgression;

        // Calculate the expected progression based on the defined ProgramCredits
        final int expectedProgression = (45 / programCredits.programsCredits['7694']! * 100).round();

        // Verify that the calculated progression matches the expected value
        expect(progression, expectedProgression);
      });

      test("handles no matching program code", () {
        // Create a list of programs with no matching program code
        final List<Program> programWithUnknownCode = [
          Program(
            name: 'Program X',
            code: '9999', // Program code with no matching entry in ProgramCredits
            average: '3.00',
            accumulatedCredits: '20',
            registeredCredits: '40',
            completedCourses: '5',
            failedCourses: '2',
            equivalentCourses: '0',
            status: 'Actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: programWithUnknownCode);

        // Calculate the program progression
        final int progression = viewModel.programProgression;

        // The expected progression should be 0 when there is no matching program code
        expect(progression, 0.0);
      });
    });

    group('refresh -', () {
      test('Call SignetsAPI to get the user info and programs', () async {
        UserRepositoryMock.stubProfileStudent(userRepositoryMock, toReturn: info);
        UserRepositoryMock.stubGetInfo(userRepositoryMock, toReturn: info);
        UserRepositoryMock.stubGetPrograms(userRepositoryMock);

        await viewModel.refresh();

        expect(viewModel.profileStudent, info);

        verifyInOrder([userRepositoryMock.getInfo(), userRepositoryMock.getPrograms(), userRepositoryMock.info]);

        verifyNoMoreInteractions(userRepositoryMock);
      });
    });

    group('Programs with "Microprogramme [...] enseignement cooperatif" should not be the default program', () {
      test('Bac program with no internships (microprogramme)', () async {
        final List<Program> bacProgramOnly = [
          Program(
            name: 'Baccalauréat en génie logiciel ',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '20',
            registeredCredits: '0',
            completedCourses: '10',
            failedCourses: '1',
            equivalentCourses: '0',
            status: 'actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: bacProgramOnly);

        expect(bacProgramOnly.first, viewModel.getCurrentProgram());
      });

      test('Bac program with 1 active internship (microprogramme)', () async {
        final List<Program> bacProgramWithActiveInternship = [
          Program(
            name: 'Baccalauréat en génie logiciel ',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '20',
            registeredCredits: '0',
            completedCourses: '10',
            failedCourses: '1',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif I',
            code: '0725',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '0',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: bacProgramWithActiveInternship);

        expect(bacProgramWithActiveInternship.first, viewModel.getCurrentProgram());
      });

      test('Bac program with 1 active internship (microprogramme) and 1 completed', () async {
        final List<Program> bacProgramWithMixedInternships = [
          Program(
            name: 'Baccalauréat en génie logiciel ',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '20',
            registeredCredits: '0',
            completedCourses: '10',
            failedCourses: '1',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif I',
            code: '0725',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '0',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Dossier fermé',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif II',
            code: '0726',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '0',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: bacProgramWithMixedInternships);

        expect(bacProgramWithMixedInternships.first, viewModel.getCurrentProgram());
      });

      test('Maitrise program with 3 completed internships', () async {
        final List<Program> maitriseWithCompletedInternships = [
          Program(
            name: 'Baccalauréat en génie logiciel ',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '116',
            registeredCredits: '0',
            completedCourses: '40',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Diplome',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif I',
            code: '0725',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '0',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Dossier fermé',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif II',
            code: '0726',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '0',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Dossier fermé',
          ),
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif III',
            code: '0727',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '0',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Dossier fermé',
          ),
          Program(
            name: 'Maîtrise en génie logiciel',
            code: '1822',
            average: '3.00',
            accumulatedCredits: '4',
            registeredCredits: '12',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: maitriseWithCompletedInternships);

        expect(maitriseWithCompletedInternships.last, viewModel.getCurrentProgram());
      });
    });

    group('getCurrentProgram', () {
      test('should prioritize "diplômé" over other non-active statuses', () async {
        final List<Program> programsWithMixedStatuses = [
          Program(
            name: 'Baccalauréat en informatique',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '90',
            registeredCredits: '0',
            completedCourses: '30',
            failedCourses: '1',
            equivalentCourses: '0',
            status: 'suspendu',
          ),
          Program(
            name: 'Baccalauréat en génie logiciel',
            code: '7625',
            average: '3.50',
            accumulatedCredits: '120',
            registeredCredits: '0',
            completedCourses: '40',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'diplômé',
          ),
          Program(
            name: 'Certificat en programmation',
            code: '4000',
            average: '2.80',
            accumulatedCredits: '30',
            registeredCredits: '0',
            completedCourses: '10',
            failedCourses: '2',
            equivalentCourses: '0',
            status: 'abandonné',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(programsWithMixedStatuses));

        expect(viewModel.getCurrentProgram(), programsWithMixedStatuses[1]);
      });

      test('should return last program when multiple active programs exist', () async {
        final List<Program> multipleActivePrograms = [
          Program(
            name: 'Baccalauréat en informatique',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '60',
            registeredCredits: '15',
            completedCourses: '20',
            failedCourses: '1',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Certificat en programmation',
            code: '4000',
            average: '3.20',
            accumulatedCredits: '20',
            registeredCredits: '10',
            completedCourses: '6',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Baccalauréat en Génie Logiciel',
            code: '4264',
            average: '3.10',
            accumulatedCredits: '15',
            registeredCredits: '20',
            completedCourses: '7',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(multipleActivePrograms));

        expect(viewModel.getCurrentProgram(), multipleActivePrograms.last);
      });

      test('should return last program when multiple graduated programs exist', () async {
        final List<Program> multipleGraduatedPrograms = [
          Program(
            name: 'Baccalauréat en informatique',
            code: '7084',
            average: '3.00',
            accumulatedCredits: '120',
            registeredCredits: '0',
            completedCourses: '40',
            failedCourses: '2',
            equivalentCourses: '0',
            status: 'diplômé',
          ),
          Program(
            name: 'Certificat en programmation',
            code: '4000',
            average: '3.50',
            accumulatedCredits: '30',
            registeredCredits: '0',
            completedCourses: '10',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'diplômé',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(multipleGraduatedPrograms));

        expect(viewModel.getCurrentProgram(), multipleGraduatedPrograms.last);
      });

      test('should fallback to last program with any status when no active or graduated programs exist', () async {
        final List<Program> programsWithNonActiveStatuses = [
          Program(
            name: 'Baccalauréat en informatique',
            code: '7084',
            average: '2.50',
            accumulatedCredits: '45',
            registeredCredits: '0',
            completedCourses: '15',
            failedCourses: '3',
            equivalentCourses: '0',
            status: 'suspendu',
          ),
          Program(
            name: 'Certificat en programmation',
            code: '4000',
            average: '2.80',
            accumulatedCredits: '15',
            registeredCredits: '0',
            completedCourses: '5',
            failedCourses: '2',
            equivalentCourses: '0',
            status: 'abandonné',
          ),
          Program(
            name: 'Maîtrise en génie logiciel',
            code: '1822',
            average: '3.50',
            accumulatedCredits: '20',
            registeredCredits: '10',
            completedCourses: '6',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'suspendu',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(programsWithNonActiveStatuses));

        expect(viewModel.getCurrentProgram().name, programsWithNonActiveStatuses.last.name);
      });

      test('should correctly filter out internship programs with different cycle numbers', () async {
        final List<Program> programsWithMultiCycleInternships = [
          Program(
            name: 'Maîtrise en génie logiciel',
            code: '1822',
            average: '3.50',
            accumulatedCredits: '20',
            registeredCredits: '10',
            completedCourses: '6',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Microprogramme de 2e cycle en enseignement coopératif',
            code: '0825',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '0',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Microprogramme de 3e cycle en enseignement coopératif',
            code: '0925',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '0',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'abandonné',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(programsWithMultiCycleInternships));

        expect(viewModel.getCurrentProgram(), programsWithMultiCycleInternships.first);
      });

      test('should return active internship if no active non-internship programs exist', () async {
        final List<Program> onlyInternshipPrograms = [
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif I',
            code: '0725',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '1',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'actif',
          ),
          Program(
            name: 'Microprogramme de 2e cycle en enseignement coopératif II',
            code: '0726',
            average: '',
            accumulatedCredits: '9',
            registeredCredits: '2',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'Dossier fermé',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(onlyInternshipPrograms));

        expect(viewModel.getCurrentProgram(), onlyInternshipPrograms.first);
      });

      test('should correctly filter out internship programs with different cycle numbers', () async {
        final List<Program> onlyCompletedInternships = [
          Program(
            name: 'Microprogramme de 1er cycle en enseignement coopératif I',
            code: '0725',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'gradué',
          ),
          Program(
            name: 'Microprogramme de 2e cycle en enseignement coopératif',
            code: '0825',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '0',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'gradué',
          ),
          Program(
            name: 'Microprogramme de 3e cycle en enseignement coopératif',
            code: '0925',
            average: '',
            accumulatedCredits: '0',
            registeredCredits: '9',
            completedCourses: '1',
            failedCourses: '0',
            equivalentCourses: '0',
            status: 'gradué',
          ),
        ];

        UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: List.from(onlyCompletedInternships));

        expect(viewModel.getCurrentProgram(), onlyCompletedInternships.last);
      });
    });
  });
}
