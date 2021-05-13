// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/user_repository.dart';

// VIEW
import 'package:notredame/ui/views/profile_view.dart';

import '../../helpers.dart';

// MOCKS
import '../../mock/managers/user_repository_mock.dart';
import '../../mock/services/networking_service_mock.dart';

void main() {
  AppIntl intl;
  UserRepository userRepository;
  NetworkingServiceMock networkingService;
  group('Profile view - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      userRepository = setupUserRepositoryMock();

      UserRepositoryMock.stubGetInfo(userRepository as UserRepositoryMock);

      UserRepositoryMock.stubGetPrograms(userRepository as UserRepositoryMock);

      // Stub to simulate that the user has an active internet connection
      NetworkingServiceMock.stubHasConnectivity(networkingService);
    });

    tearDown(() {
      unregister<NetworkingServiceMock>();
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

      expect(find.widgetWithText(ListTile, intl.login_prompt_universal_code),
          findsOneWidget);
    });

    group("golden - ", () {
      testWidgets("default view (no events)", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: ProfileView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ProfileView),
            matchesGoldenFile(goldenFilePath("profileView_1")));
      });
    });
  });
}
