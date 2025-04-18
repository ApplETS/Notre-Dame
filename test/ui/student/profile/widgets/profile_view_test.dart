// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/profile_student.dart';
import 'package:notredame/data/services/signets-api/models/program.dart';
import 'package:notredame/ui/student/profile/widgets/profile_view.dart';
import '../../../../data/mocks/repositories/user_repository_mock.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;
  late UserRepositoryMock userRepositoryMock;

  final profileStudent = ProfileStudent(
      firstName: "John", lastName: "Doe", permanentCode: "ABC123", balance: "123456789", universalCode: 'AA000000');

  // Make a test program object
  final program = Program(
      name: "Program name",
      code: "1234",
      average: "4.20",
      accumulatedCredits: "123",
      registeredCredits: "123",
      completedCourses: "123",
      failedCourses: "123",
      equivalentCourses: "123",
      status: "Actif");

  final programList = [program];

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

      expect(find.text(program.name), findsNWidgets(2));
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
  });
}
