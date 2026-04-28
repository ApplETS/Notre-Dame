// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/login/widgets/login_view.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/auth_service_mock.dart';
import '../../../data/mocks/services/navigation_service_mock.dart';
import '../../../data/mocks/services/networking_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late NavigationServiceMock navigationServiceMock;
  late SettingsRepositoryMock settingsRepositoryMock;
  late NetworkingServiceMock networkingServiceMock;
  late AuthServiceMock authServiceMock;

  late AppIntl appIntl;

  group('LoginView', () {
    setUp(() async {
      setupAnalyticsServiceMock();
      navigationServiceMock = setupNavigationServiceMock();
      settingsRepositoryMock = setupSettingsRepositoryMock();
      networkingServiceMock = setupNetworkingServiceMock();
      authServiceMock = setupAuthServiceMock();

      appIntl = await setupAppIntl();
    });

    tearDown(() {
      unregister<AuthService>();
      unregister<NetworkingService>();
      unregister<UserRepository>();
      unregister<SettingsRepository>();
      unregister<NavigationService>();
      unregister<AnalyticsService>();
    });

    group('UI', () {
      testWidgets('has 2 buttons with an icon, title and school logo', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const LoginView()));
        await tester.pumpAndSettle();

        final heroFinder = find.byType(Hero);
        expect(heroFinder, findsOneWidget);
        final Hero heroWidget = tester.widget(heroFinder);
        expect(heroWidget.tag, 'ets_logo');
        expect(find.text(appIntl.login_startup_title), findsOneWidget);
        expect(find.byIcon(FontAwesomeIcons.lockOpen), findsOneWidget);
        expect(find.text(appIntl.login_action_sign_in), findsOneWidget);
        expect(find.byIcon(FontAwesomeIcons.question), findsOneWidget);
        expect(find.text("FAQ"), findsOneWidget);
      });

      testWidgets('sign in button triggers authentication', (WidgetTester tester) async {
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
        SettingsRepositoryMock.stubIsLocaleDefined(settingsRepositoryMock, toReturn: true);

        await tester.pumpWidget(localizedWidget(child: const LoginView()));
        await tester.pumpAndSettle();

        final signInButton = find.byIcon(FontAwesomeIcons.lockOpen);
        await tester.tap(signInButton);
        await tester.pump();
        verify(authServiceMock.acquireToken()).called(1);
      });

      testWidgets('FAQ button navigates to the FAQ page', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const LoginView()));
        await tester.pumpAndSettle();

        final faqButton = find.text("FAQ");
        await tester.tap(faqButton);
        await tester.pumpAndSettle();
        verify(navigationServiceMock.pushNamed(RouterPaths.faq)).called(1);
      });
    });
  });
}
