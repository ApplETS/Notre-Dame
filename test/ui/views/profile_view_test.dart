// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/profile_view.dart';
import '../../helpers.dart';
import '../../mock/managers/user_repository_mock.dart';
import '../../mock/services/analytics_service_mock.dart';

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
