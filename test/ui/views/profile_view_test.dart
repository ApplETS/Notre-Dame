// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// MANAGERS
import 'package:notredame/core/managers/user_repository.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';
import '../../mock/services/analytics_service_mock.dart';

// VIEW
import 'package:notredame/ui/views/profile_view.dart';

import '../../helpers.dart';

// MOCKS
import '../../mock/managers/user_repository_mock.dart';

void main() {
  AppIntl intl;
  UserRepository userRepository;

  final profileStudent = ProfileStudent(
      firstName: "John",
      lastName: "Doe",
      permanentCode: "ABC123",
      balance: "123456789");

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
      userRepository = setupUserRepositoryMock();
      setupAnalyticsServiceMock();

      UserRepositoryMock.stubGetInfo(userRepository as UserRepositoryMock,
          toReturn: profileStudent);
      UserRepositoryMock.stubProfileStudent(
          userRepository as UserRepositoryMock,
          toReturn: profileStudent);

      UserRepositoryMock.stubGetPrograms(userRepository as UserRepositoryMock,
          toReturn: programList);

      UserRepositoryMock.stubPrograms(userRepository as UserRepositoryMock,
          toReturn: programList);
    });

    tearDown(() {
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    testWidgets('contains main info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(
          find.text("${profileStudent.firstName} ${profileStudent.lastName}"),
          findsOneWidget);

      expect(find.text(program.name), findsNWidgets(2));
    });

    testWidgets('contains personal info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text(profileStudent.permanentCode), findsOneWidget);

      expect(find.text(intl.profile_permanent_code), findsOneWidget);

      expect(find.text(intl.login_prompt_universal_code), findsOneWidget);
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
    });

    group("golden - ", () {
      testWidgets("default view (no events)", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);

        await tester.pumpWidget(localizedWidget(child: ProfileView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ProfileView),
            matchesGoldenFile(goldenFilePath("profileView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
