import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/ui/views/profile_view.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

import '../../helpers.dart';
import '../../mock/managers/user_repository_mock.dart';

void main() {
  AppIntl intl;
  UserRepository userRepository;
  group('Profile view - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      userRepository = setupUserRepositoryMock();
    });

    tearDown(() {});

    testWidgets('contains one listView', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      final listView = find.byType(ListView);
      expect(listView, findsNWidgets(1));
    });

    testWidgets('contains student status', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, intl.profile_student_status_title),
          findsOneWidget);

      expect(
          find.widgetWithText(ListTile, intl.profile_balance), findsOneWidget);
    });

    testWidgets('contains personal info', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: ProfileView()));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithText(
              ListTile, intl.profile_personal_information_title),
          findsOneWidget);

      expect(find.widgetWithText(ListTile, intl.profile_first_name),
          findsOneWidget);

      expect(find.widgetWithText(ListTile, intl.profile_last_name),
          findsOneWidget);

      expect(find.widgetWithText(ListTile, intl.profile_permanent_code),
          findsOneWidget);
    });

    group("golden - ", () {
      testWidgets("default view (no events)", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        UserRepositoryMock.stubGetInfo(userRepository as UserRepositoryMock);

        UserRepositoryMock.stubGetPrograms(
            userRepository as UserRepositoryMock);

        await tester.pumpWidget(localizedWidget(child: ProfileView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ProfileView),
            matchesGoldenFile(goldenFilePath("profileView_1")));
      });
    });
  });
}
