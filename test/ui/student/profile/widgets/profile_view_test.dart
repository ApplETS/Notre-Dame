// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/student/profile/widgets/profile_view.dart';
import 'package:notredame/ui/student/widgets/student_program.dart';
import '../../../../data/mocks/repositories/user_repository_mock.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;
  late UserRepositoryMock userRepositoryMock;

  final profileStudent = ProfileStudent(
      firstName: "John", lastName: "Doe", permanentCode: "ABC123", balance: "123456789", universalCode: 'AA000000');

  final programList = [
    Program(
      name: 'Baccalauréat en génie logiciel ',
      code: '7084',
      average: '3.00',
      accumulatedCredits: '116',
      registeredCredits: '0',
      completedCourses: '40',
      failedCourses: '0',
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

  group('Profile view - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      userRepositoryMock = setupUserRepositoryMock();
      setupAnalyticsServiceMock();

      UserRepositoryMock.stubGetInfo(userRepositoryMock, toReturn: profileStudent);
      UserRepositoryMock.stubProfileStudent(userRepositoryMock, toReturn: profileStudent);

      UserRepositoryMock.stubGetPrograms(userRepositoryMock, toReturn: programList);

      UserRepositoryMock.stubPrograms(userRepositoryMock, toReturn: programList);
    });

    tearDown(() {
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    testWidgets('contains main info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text("${profileStudent.firstName} ${profileStudent.lastName}"), findsOneWidget);

      expect(find.text(programList[0].name), findsNWidgets(2));
    });

    testWidgets('contains personal info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text(profileStudent.permanentCode), findsOneWidget);

      expect(find.text(intl.profile_permanent_code), findsOneWidget);

      expect(find.text(intl.login_prompt_universal_code), findsOneWidget);
    });

    testWidgets('copies personnal info', (WidgetTester tester) async {
      // Simulez un clic sur le texte du code permanent
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(profileStudent.permanentCode));
      await tester.pumpAndSettle();

      expect(find.text(intl.profile_permanent_code_copied_to_clipboard), findsOneWidget);

      // Could not test clipboard content, could be due to https://github.com/flutter/flutter/issues/47448
    });

    testWidgets('contains balance info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text(profileStudent.balance), findsOneWidget);

      expect(find.text(intl.profile_balance), findsOneWidget);
    });

    testWidgets('contains program completion', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text(intl.profile_program_completion), findsOneWidget);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('contains "other" programs section', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text(intl.profile_other_programs), findsOneWidget);

      expect(find.byType(StudentProgram), findsNWidgets(2));
      expect(find.text(programList[1].name), findsOneWidget);
      expect(find.text(programList[2].name), findsOneWidget);
    });
  });
}
